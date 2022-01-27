# Workflow Template - Nextflow
Template for building a small workflow in Nextflow

## Background

[Nextflow](https://www.nextflow.io/) is a free and open source software
project which makes it easier to run a computational workflow consisting
of a series of interconnected steps. There are many different ways that
Nextflow can be used, and the [documentation](https://www.nextflow.io/docs/latest/index.html)
can be overwhelming. This repository provides an opinionated example of
how a bioinformatician can structure their code to be run using Nextflow.

## Use DSL-2

After getting started, Nextflow added a lot of extremely useful functionality in
a major release. Since that new functionality was not always backwards compatible,
the new syntax was called "DSL-2". There is [extensive documentation](https://www.nextflow.io/docs/latest/dsl2.html)
on the DSL-2 syntax. The only thing you need to do inside a workflow to use
these features is to add `nextflow.enable.dsl=2` at the top of `main.nf`.

It is worth your time to read over the DSL-2 documentation if you want to
write workflows which are elegant and easy to maintain.

## Repository Structure

The essential components of the workflow repository are:
- `main.nf`: Contains the primary workflow code which pulls in all additional code from the repository
- `modules/`: Contains all of the sub-workflows which are used to organize large chunks of analysis
- `templates/`: Contains all of the code which is executed in each individual step of the workflow

## Parameter Inheritance

When running a workflow you can tell it what to do by passing in parameters with
`--param_name param_value`. To make this work easily in Nextflow, make sure to
set up the default value in `nextflow.config` in the `params` scope (e.g. `params{param_name = 'default_value'}`).
If a user passes in a value, then `params.param_name` will have that value. If they
do not, it will be `default_value`. The really useful thing about the `params` is that
they are inherited by every sub-workflow and process that is invoked. In other words,
without having to do _anything_ else, I can use `${params.param_name}` in one of the
script files in `templates/`, and I know that it will contain the value that was provided
by the user. 

There are options to override this parameter inheritance if you want to get really fancy,
but this default behavior is extremely useful if you just want to write code and not
worry about explicitly piping together each of the variables into each sub-workflow
as it is imported.

### User Input of Parameters

There are two ways that users can most easily provide their own inputs to a workflow,
with command-line flags or with a params file.

On the command line, parameters are provided using two dashes before the parameter
name, e.g. `--param_name value`. One limitation of this approach is that the provided
value will be interpreted as a string. The best example of this is the edge case of the
the negative boolean (`false`), which will be interpreted by Nextflow as a string (`'false'`).
The second limitation is that the command line string starts to become rather long.
Another consideration of providing parameters on the command line is that they may be
interpreted by the shell before execution. For example, in the context of a BASH script
`--param_name *.fastq.gz` will first be expanded to the list of files which match that
pattern (e.g., `--param_name 1.fastq.gz 2.fastq.gz 3.fastq.gz`), which may not be the
intention. This behavior can be prevented explicitly with single-quotes in BASH, with
`--param_name '*.fastq.gz'` being unaltered by the shell before execution.

By using a params file, the user is able to more explicitly define the set of parameters
which will be provided. The params file can be formatted as JSON or YAML, with the example
below shown in JSON.

```
{
    "param_name": "*.fastq.gz",
    "second_param": false,
    "third_param": 5
}
```

The params file is provided by the user with the `-params-file` flag.
While this approach requires the user to create an additional file, it also provides a
method for defining variables without worrying about the nuances of the shell interpreter.

If both methods are used for providing parameters, the command line flags will take
precedence over the params file ([docs](https://www.nextflow.io/docs/latest/config.html)).

## Templates

One of the options for defining the code that is run inside a Nextflow process
is to use their [template syntax](https://www.nextflow.io/docs/latest/process.html#template).
The advantage of this approach is that the code can be defined in a separate file
with the appropriate file extension which can be recognized by your favorite IDE
and linter. Any variables from Nextflow will be interpolated using an easy `${var_name}`
syntax, and all other code will be native to the desired language. 

The one 'gottcha' for the template structure is the backslashes are used to escape Nextflow interpolation (meaning that internal BASH variables can be specified with `\$INTERNAL_VAR_NAME`),
and so any use of backslashes for special characters must have two backslashes. Put simply,
if you want to strip the newline character in Python, you would need to write `str.strip('\\n')`
instead of `str.strip('\n')`.

## Software Containers

Each individual step in a workflow should be run inside a container (using
either Docker or Singularity) which has the required dependencies. There is a
long list of public images with commonly used bioinformatics tools available
at the [BioContainers Registry](https://biocontainers.pro/registry). Specific builds
should be identified from the [corresponding repository](https://quay.io/repository/biocontainers/bwa?tab=tags)
for use in a workflow.

Software containers should be defined as parameters in `main.nf`, which allows
the value to propagate automatically to all imported sub-workflows, while also
being able to be overridden easily by the user if needs be.

Practically speaking, this means that every process should have a `container`
declared which follows the pattern `container "${params.container__toolname}"`,
and which was set in `nextflow.config` with `params{container__toolname = "quay.io/org/image:tag"}`.
It is crucial that the parameter be set _before_ the subworkflows are imported, as
shown in this example workflow.

## Workflow Style Guide

While a workflow could be made in almost any way imaginable, there are some
tips and tricks which make debugging and development easier. This is a highly
opinionated list, and should be taken simply as one perspective on the topic.

- Never use file names to encode metadata (like specimen name, `.trimmed`, etc.)
- Always publish files with `mode: 'copy', overwrite: true`
- Use `.toSortedList()` instead of `.collect()` for reproducible ordering
- Add `set -Eeuo pipefail` to the header of any BASH script
- Every process uses a `container`, which is defined as a `param.container__toolname` in `main.nf`
- Never use `.baseName` to remove file extension, instead use (e.g.) `.name.replaceAll('.fastq.gz', '')`

## Going Further

If you are interested in writing workflows in a way which can be best
shared with the worldwide community of Nextflow developers, please join the 
[nf-core](https://nf-co.re/) community. In addition to providing a catalog of
increcibly useful workflows, this group of core bioinformaticians has created an entire
software suite for authoring workflows using community-driven best practices.

The nf-core codebase can be used to quickly create workflow templates (`nf-core create`)
which are far more sophisticated and robust than this repository. The code here is
for a quick-and-dirty launch into Nextflow. If you want to go deeper, connect with
the other people around the world who have already put in the work to build a
community, and you will go farther together.
