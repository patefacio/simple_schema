# Simple Schema



<!--- custom <introduction> --->

A library to define Json Schema that supports only a constrained but reasonable subset of the standard.

<!--- end <introduction> --->


# Purpose

<!--- custom <purpose> --->

Json Schema is sophisticated. Schema can contain schema, schema properties can themselves be schema (if referenced or anything else if not), sub-schema can be defined inline or in _#/definitions_, and there are a *huge* number of options that can be set. This is a strength of Json Schema, but could be viewed as a weakness if one just wants a simple schema to store structured JSON. For instance, POD data structures are very commonly used to pass data between client and server and in general the data has a shape that can be described much like a simple _C_ structure. This library provides a Dart declarative api for the creation of _simple schema_. With this approach there are no *inline* schemas.

By constraining the usage of _JSON Schema_ to a simple subset, they become much more amenable to support via code generation. Included in this package is code generation support for creating equivalent Dart and D POD data structures with Json serialization built in.

<!--- end <purpose> --->


<!--- custom <body> --->

# Approach

The starting point for creating a simple schema is the _package_ function which returns a _Package_. A _Package_ is a collection of types where each type is either a basic Json Schema primitive type [_integer_, _boolean_, _object_, ...] or a _SimpleSchema_. All types that are _SimpleSchema_ are defined in '#/definitions'. Every _SimpleSchema_ must have a unique identifier identifying it within the _Package_ and it is enforced. There are no namespaces, so if you want an _AddressBook_  in your _SimpleSchema_, that schema must be named and there can only be one such _AddressBook_ in the _Package_. 

<!--- end <body> --->


# Examples

<!--- custom <examples> --->
<!--- end <examples> --->




