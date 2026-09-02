# Bacterial genome annotation and structural variation detection
A couple of short Snakemake scripts using sample data from _Mycobacterium avium_ subsp. _hominissuis_ (MAH) and _Mycobacterium avium_ subsp. _paratuberculosis_ (MAP) as examples.


## Set up the environment: 
```
cd MAH_SVs
conda env create --name sv --file sv_configs/env_sv.yaml 
conda activate sv
```

## Organize your data
These scripts were originally written for a student to show them how to annotate multiple bacterial genomes then compare those to a reference genome. The exact file structure and naming is depicted below, but in general, the sequence files for each strain/sample should be in a directory with the same root name to help keep things organized and simplify wildcard assignment.

```
├── MAH_SVs  
│   ├── fastq_files  
|   │   ├── SRR13195563  
|   │   │   ├── SRR13195563.fastq.gz  
|   │   ├── SRR33905603
|   │   │   ├── SRR33905603.fastq.gz  
|   │   ├── SRR34136513
|   │   │   ├── SRR34136513.fastq.gz  
│   ├── MAH_genomes
|   │   ├── GCF_000829075  
|   │   │   ├── GCF_000829075_genomic.fna  
|   │   ├── GCF_038446155
|   │   │   ├── GCF_038446155_genomic.fna  
|   │   ├── GCF_964205045
|   │   │   ├── GCF_964205045_genomic.fna  
│   ├── MAP_genomes
|   │   ├── GCF_025665475.K10_genomic.fna
```


## Annotate MAH genomes using Bakta 
If you already downloaded the Bakta database, make sure it's the latest version using `bakta_db update`
```
snakemake -s genome_annot.smk --verbose --cores 1 --slurm --profile sv_configs/
```

## Detect structural variants between MAH genomes and the MAP reference genome
```
snakemake -s seq_sv.smk --verbose --cores 1 --slurm --profile sv_configs/
```
Then, to get a quick count of each SV type for each strain: 
``` 
for file in fastq_files/*/*_sv.vcf; do s=$( echo "$file" | cut -f 2 -d '/' ); echo ''; echo "$s"; grep -v '^#' "$file" | cut -f 3 | cut -f 2 -d '.' | sort | uniq -c; done 
```
If you used the accessions listed above and everything ran correctly, you should get this output:
```
SRR13195563
     36 DEL
      2 DUP
     38 INS
     14 INV

SRR33905603
    120 DEL
      5 DUP
    108 INS
      6 INV

SRR34136513
    131 DEL
      4 DUP
    118 INS
      7 INV
```

Note: Snakemake version 7.32.4 is included in the environment file because it was the latest version I could get to work on our compute cluster with the SLURM job scheduler when I originally wrote this a couple years ago (I have since used Snakemake v8.18.2 which works wonderfully with SLURM, but I haven't tested these scripts with it). So, if you get `"AttributeError: module 'lib' has no attribute 'X509_V_FLAG_NOTIFY_POLICY'"` error, you may have to update pyOpenSSL: `pip3 install pyOpenSSL --upgrade`, but I would suggest just using a more recent version of Snakemake (make sure you update the Snakemake command and config.yaml appropriately).
