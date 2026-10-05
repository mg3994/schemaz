import '../core/node.dart';
import '../core/registry.dart';
import '../core/schema.dart';
import '../parser/ast.dart';

class Environment {
  final Environment? parent;
  final Map<String, dynamic> _bindings = {};

  Environment({this.parent});

  void define(String name, dynamic value) {
    _bindings[name] = value;
  }

  dynamic get(String name) {
    if (_bindings.containsKey(name)) {
      return _bindings[name];
    }
    if (parent != null) {
      return parent!.get(name);
    }
    throw FormatException('Undefined identifier "$name"');
  }

  void assign(String name, dynamic value) {
    if (_bindings.containsKey(name)) {
      _bindings[name] = value;
      return;
    }
    if (parent != null) {
      parent!.assign(name, value);
      return;
    }
    throw FormatException('Undefined identifier "$name"');
  }
}

class ReturnValue {
  final dynamic value;
  ReturnValue(this.value);
}

class SchemazInterpreter {
  final SchemaRegistry registry;
  final Environment globalEnv = Environment();

  SchemazInterpreter({SchemaRegistry? registry})
      : registry = registry ?? SchemaRegistry() {
    _bindBuiltins();
  }

  void _bindBuiltins() {
    globalEnv.define('print', (List<dynamic> args) {
      final msg = args.map((a) => a.toString()).join(' ');
      print(msg);
      return msg;
    });
  }

  dynamic evaluateProgram(ProgramNode program) {
    dynamic lastResult;
    for (final stmt in program.statements) {
      lastResult = evaluate(stmt, globalEnv);
    }
    return lastResult;
  }

  dynamic evaluate(ASTNode node, Environment env) {
    if (node is SchemaDeclNode) {
      final schema = Schema(
        name: node.name,
        parents: node.parentName != null ? [registry.lookupSchema(node.parentName!)!] : [],
      );
      for (final prop in node.properties) {
        final propType = registry.lookup(prop.typeName);
        if (propType != null) {
          schema.addProperty(PropertyDefinition(name: prop.name, type: propType));
        }
      }
      registry.registerType(schema);
      return schema;
    }

    if (node is InstanceDeclNode) {
      final schema = registry.lookupSchema(node.schemaName) ??
          Schema(name: node.schemaName);
      final props = <String, dynamic>{};
      node.properties.forEach((key, expr) {
        props[key] = evaluate(expr, env);
      });
      final nodeInst = Node(schema: schema, properties: props);
      env.define(node.name, nodeInst);
      return nodeInst;
    }

    if (node is FunctionDeclNode) {
      env.define(node.name, (List<dynamic> args) {
        final fnEnv = Environment(parent: globalEnv);
        for (int i = 0; i < node.parameters.length; i++) {
          final param = node.parameters[i];
          final argVal = i < args.length ? args[i] : null;
          fnEnv.define(param.name, argVal);
        }

        try {
          dynamic fnLast;
          for (final stmt in node.body) {
            fnLast = evaluate(stmt, fnEnv);
          }
          return fnLast;
        } on ReturnValue catch (ret) {
          return ret.value;
        }
      });
      return null;
    }

    if (node is LetDeclNode) {
      final val = evaluate(node.initializer, env);
      env.define(node.name, val);
      return val;
    }

    if (node is ReturnNode) {
      final val = node.expression != null ? evaluate(node.expression!, env) : null;
      throw ReturnValue(val);
    }

    if (node is TypeCastNode) {
      final val = evaluate(node.expression, env);
      final targetSchema = registry.lookupSchema(node.targetTypeName);
      if (val is Node && targetSchema != null) {
        if (!val.schema.inheritsFrom(targetSchema)) {
          throw FormatException('TypeCastException: Cannot cast ${val.schema.name} to ${targetSchema.name}');
        }
      }
      return val;
    }

    if (node is LiteralNode) {
      return node.value;
    }

    if (node is ListLiteralNode) {
      return node.elements.map((e) => evaluate(e, env)).toList();
    }

    if (node is MapLiteralNode) {
      final map = <String, dynamic>{};
      node.entries.forEach((k, v) {
        map[k] = evaluate(v, env);
      });
      return map;
    }

    if (node is IdentifierNode) {
      return env.get(node.name);
    }

    if (node is BinaryOpNode) {
      final left = evaluate(node.left, env);
      final right = evaluate(node.right, env);
      switch (node.operator) {
        case '+':
          return (left is String || right is String) ? '$left$right' : left + right;
        case '-':
          return left - right;
        case '*':
          return left * right;
        case '/':
          return left / right;
        case '==':
          return left == right;
        case '!=':
          return left != right;
        case '>':
          return left > right;
        case '>=':
          return left >= right;
        case '<':
          return left < right;
        case '<=':
          return left <= right;
        default:
          throw FormatException('Unsupported operator ${node.operator}');
      }
    }

    if (node is PropertyAccessNode) {
      final target = evaluate(node.target, env);
      if (target is Node) {
        return target.get(node.propertyName);
      }
      if (target is Map) {
        return target[node.propertyName];
      }
      throw FormatException('Cannot access property ${node.propertyName} on non-node/map $target');
    }

    if (node is FunctionCallNode) {
      final fn = env.get(node.callee);
      final args = node.arguments.map((a) => evaluate(a, env)).toList();
      if (fn is Function) {
        return fn(args);
      }
      throw FormatException('${node.callee} is not a function');
    }

    if (node is MethodCallNode) {
      final target = evaluate(node.target, env);
      final args = node.arguments.map((a) => evaluate(a, env)).toList();
      if (node.methodName == 'toString') return target.toString();
      if (target is List) {
        if (node.methodName == 'length') return target.length;
        if (node.methodName == 'contains' && args.isNotEmpty) return target.contains(args.first);
        if (node.methodName == 'sum') {
          return target.fold<num>(0, (prev, element) => prev + (element is num ? element : 0));
        }
      }
      throw FormatException('Unknown method ${node.methodName}');
    }

    return null;
  }
}
