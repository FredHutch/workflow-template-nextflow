#!/bin/bash

set -euo pipefail

# Count up the number of aligned reads
samtools flagstats "${bam}" > "${specimen}.flagstats"
