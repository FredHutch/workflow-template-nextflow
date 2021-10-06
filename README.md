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

## Workflow Style Guide

While a workflow could be made in almost any way imaginable, there are some
tips and tricks which make debugging and development easier. This is a highly
opinionated list, and should be taken simply as one perspective on the topic.

- Never use file names to encode metadata (like specimen name, `.trimmed`, etc.)
- Always publish files with `mode: 'copy', overwrite: true`
- Use `.toSortedList()` instead of `.collect()` for reproducible ordering
- Add `set -Eeuo pipefail` to the header of any BASH script
