# Simple Schema



<!--- custom <introduction> --->

A library to define Json Schema that supports only a constrained but reasonable subset of the standard.

<!--- end <introduction> --->


# Purpose

<!--- custom <purpose> --->

Json Schema is sophisticated. Schema can contain schema, schema properties can themselves be schema (if referenced or anything else if not), sub-schema can be defined inline or in _#/definitions_, and there are a *huge* number of options that can be set. This is a strength of Json Schema, but could be viewed as a weakness if one just wants a simple schema to store structured JSON. For instance, POD data structures are very commonly used to pass data between client and server and in general the data has a shape that can be described much like a simple _C_ structure. This library provides a Dart declarative api for the creation of _simple schema_. With this approach there are no *inline* schemas.

By constraining the usage of _JSON Schema_ to a simple subset, they become much more amenable to support via code generation. Included in this package is code generation support for creating equivalent Dart and D POD data structures with Json serialization built in.

So, what is Json, really. It is a set of fundamental types:

- boolean
- integer
- number
- string
- array
- object
- null

Of these, array and object are special. They can be thought of as and are in fact collections of other json. This is then a recursive design. The recursive pattern allows the structure of an object to be composed of other objects built from the same original set of types.

Wouldn't it be nice to have a simple way define such types in a straightforward way. Well, there exist many technologies allowing for just this ability to define structure (or schema).

- Protobuf
- Thrift
- Avro
- XML Schema
- Json Schema

Some of these were defined with specific goals in mind: For example, Protobuf seems to be about defining schema in a strict enough manner to allow for the generation of efficient serialization code in all sorts of languages. Thrift and Avro are similar in that regard. At the other end of the spectrum are those that shun the practice of defining schema but prefer to have the code they write dictate and manage the shape of their data. In that game, due to the simplicity, just sending Json seems to be what has won favor for those types. 

Defining _SimpleSchema_ to have just enough schema to be useful for simple cases will allow:

- A schema definition to be used with data

- An ability to have that schema be stored in more sophisticated meta
  data format _Json Schema_. This allows any benefits that come with
  _Json Schema_ to apply.

- A hopefully convenient model for that schema, at least for those using Dart

- The focus can be on the model. It should be straightforward to find a suitable mapping from _SimpleSchema_ to any of the others.


<!--- end <purpose> --->


<!--- custom <body> --->

# Approach

The starting point for creating a simple schema is the _package_ function which returns a _Package_. A _Package_ is a collection of _SimpleSchema_, also called _types_. Each type is either a basic Json Schema primitive type [ _integer_, _boolean_, _object_, ...] or an array of some _SimpleSchema_, or an object keyed by _string_ referring to some _SimpleSchema_. All types that are _SimpleSchema_ are defined in '#/definitions'. Every _SimpleSchema_ must have a unique identifier identifying it within the _Package_ and it is enforced. There are no namespaces, so if you want an _AddressBook_  in your _SimpleSchema_, that schema must be named and there can only be one such _AddressBook_ in the _Package_. 

<!--- end <body> --->


# Examples

<!--- custom <examples> --->
<!--- end <examples> --->




