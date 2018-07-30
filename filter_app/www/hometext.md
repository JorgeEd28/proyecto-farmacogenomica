MAP and PED files are very widely used for analyzing genotypic data. Usually, from the hundreds of thousands of variants, users are only interested in analyzing specific genes that represent a small percentage of the whole data. The **FiltPEDs Tool** is designed to generate new MAP and PED files with selected variants, based on the gene where it occurs.

It is designed for data obtained from the **Infinium Global Screening Array-24 v1.0 BeadChip**, of Illumina, customized for the Instituto Nacional de Medicina Genómica, with 669672 variants in total.

The **Annotation** module contains the full annotated probes of the microarray, annotated with Ensembl ID, gene symbol from the HUGO Gene Nomenclature Committee database and variants ID from the dbSNP database. Some variants may have associated more than one gene to them if the variant has implications on genes downstream or upstream. Some variants do not have genes associated to them if the variant occurs on introns or intergenic sites. Some variants are not found in the dbSNP database, thus they do not have an *rs* identifier; in those cases, an artificial variant id was created with the format `rs0067 + chromosome + position`; variants in chromosomes *X*, *Y*, *XY* and *MT*, take the value of 0. Users can filter the original annotation dataset by probe name, probe-variant name, chromosome, position, variant ID, Ensembl ID or gene symbol; filtered annotation dataset can be download as a CSV file.

The **Select filters** module allows filtering the annotation database with multiple values of variant IDs, Ensembl IDs or gene symbols. First, select the type of filter you want to apply; then upload a TXT/CSV file containing the values to filter, each value in a single line, such as the following example:
```
PRDM2
ADH6
STK19
BANK1
SORCS2
BRCA2
SLC2A9
ANAPC1
```
You will see a summary table with the genes and variants that your new annotation dataset contains, and the values that do not have any match.

The **Filter PED** module allows getting a MAP and a PED file, with the filtered dataset obtained in the previous module. Upload a MAP with the following format:
```
21	rs11511647	0	26765
X	rs3883674	0	32380
X	rs12218882	0	48172
9	rs10904045	0	48426
9	rs10751931	0	49949
8	rs11252127	0	52087
10	rs12775203	0	52277
8	rs12255619	0	52481
```
where the first column is the chromosome, the second the probe-variant name (as is in the annotation dataset), the third the genetic distance and the fourth the physical position. Upload a PED file with the following format:
```
FAM1	NA06985	0	0	1	1	A	T	T	T	G	G	C	C	A	T	T	T	G	G	C	C
FAM1	NA06991	0	0	1	1	C	T	T	T	G	G	C	C	C	T	T	T	G	G	C	C
FAM1	NA06993	0	0	1	1	C	T	T	T	G	G	C	T	C	T	T	T	G	G	C	T
FAM2	NA06994	0	0	1	1	C	T	T	T	G	G	C	C	C	T	T	T	G	G	C	C
FAM2	NA07000	0	0	2	1	C	T	T	T	G	G	C	T	C	T	T	T	G	G	C	T
FAM2	NA07019	0	0	1	1	C	T	T	T	G	G	C	C	C	T	T	T	G	G	C	C
FAM3	NA07022	0	0	2	1	C	T	T	T	G	G	0	0	C	T	T	T	G	G	0	0
FAM3	NA07029	0	0	1	1	C	T	T	T	G	G	C	C	C	T	T	T	G	G	C	C
FAM3	NA07056	0	0	0	2	C	T	T	T	A	G	C	T	C	T	T	T	A	G	C	T
FAM3	NA07345	0	0	1	1	C	T	T	T	G	G	C	C	C	T	T	T	G	G	C	C
```
where the first column is the family ID, the second the sample ID,  the third the paternal ID, the fourth the maternal ID, the fifth the sex (1=male; 2=female; other=unknown), the sixth the affection (0=unknown; 1=unaffected; 2=affected), and from the seventh the genotypes. *MAP and PED files must be tab-separated and without headings*. PED file must coincide with the MAP file: the number of columns on PED file must be *6 + 2n*, where *n* is the number of rows in the MAP file. Click on *Ready to filter*. You will see a message indicating the number of variants in the original MAP file and the number in the new one; additionally, you will see a summary of the samples in the PED file.

The **Download files** module allows downloading the generated files: the new MAP file, the new annotation dataset file, and the new PED file.

After you download the generated files, you can upload a new PED, MAP or filtered file.