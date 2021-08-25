# SQL JSON MAPPER

A Scalar valued function that will set and manipulate json object in Sql Server Management Studio 2019.We need to pass JSON Object ,it's Path and value that need to be set with it's type.

Open and view the Project using the `.zip` file provided or at my [Github Repository](https://github.com/https://github.com/MuhammadHashir28/SQL-JSON-Mapper).

## Table of Contents
- [Getting Started](#getting-started)
	- [Tools Required](#tools-required)
	- [Installation](#installation)
- [Development](#development)
- [Features](#features)
- [Running the App](#running-the-app)


## Getting Started

This project was built from scratch using SQL Features.

### Tools Required

No additional tools are required apart from a text editor of your choice

### Installation

No additional installation is required for this project

## Development

* Create a new Scalar function with the following:
  * Use the Required database.
  * Execute the Function. 
 
For details now how everything has been implemented, refer the source code.

## Features

* Will allow to create JSON path if the path is not present.
* Will Update the value based on it's type.
* Better than `json_modify` if we provide them path that is not presenet it will give us error.

## Running the App

* Open the project through the `.zip` file provided and extract the files. 
  > Open `JSONMapper_function.sql` in the Sql Server Management Studio and execute it on desired database.

## Example

* use the following lines to run the SQL Server Management Query.The function contains the following  types 'boolean','numeric','array','string','object'.
  > `Declare @JSON varchar(100) = '{  "employee": { "name":"sonoo"} }'`
  >`select @JSON=  dbo.JSONMapper(@JSON,'employee.ssn','AAA-GG-SSSS','string') /*this line is used to set the JSON object*/`
  > `select @JSON as Output`

