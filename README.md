## TCGA exploration workflow for Foijer lab \@ UMCG

Scripts for downloading, processing and plotting data from the TCGA/GDC. Specifically made in the context of using aneuploidy and matched RNA / genomic data for discovery of gene correlates to aneuploidy and Chromosomal INstability (CIN).

Made by Alex van Kaam, PhD student. README last updated 26-09-2025

## How metrics are calculated

#### Aneuploidy

Aneuploidy in the TCGA is measured as the seg.means, the deviation from the standard 2n (assumed) profile. We calculate this to an aneuploidy score using the following formulas. First, we convert the seg.means per bin into a CN per bin:

$$CN = (2^{seg\_mean}) *2 $$

After applying that formula we have an aneuploidy score for every bin. We can then calculate the general aneuploidy of the sample by weighting the aneuploidy score by the length of the bin:

$$aneuploidy = \displaystyle\sum_{b}^{B}  \frac{(CN - 2) * L_b}{L}$$Where b is a bin in the genomic profile, and B all the bins. L is the total length of the genome with L_b meaning the length of the bin we're calculating. Since we're assuming a base ploidy of 2 (human) we substract 2 from the calculated CN, as that would then be the deviation from the normal copy number. For those paying close attention - since seg.means is a fraction, we can have copy numbers that deviate from a discrete integer (1,2,3, etc.) and can mean that the CN can be 2.03, for example. In the grand scheme of things this doesn't seem to really matter, but for the sake of being complete we calculate both a non-rounded (with non-integer CN such as 2.03) and a rounded (requiring CN to be an integer). For downstream analysis we use the non-rounded number. Send me a message if you think this is wrong, I would be open to changing that implementation.

#### Expression

Expression from TCGA data is stored after preprocessing and with quality control included. This means we don't make any changes to the data and take it as recieved. There are a few raw data collumns which we can choose from: unstranded, strand_first and strand_second. These are not normalised to the total reads in the samples, and we therefore don't pick them. The 3 processed varieties are: TPM_unstranded (TPM = transcripts per million), FPKM_unstranded (FPKM = fragments per kilobase of transcript per million mapped reads) and FPKM_eq_usntranded. The biggest difference between TPM and FPKM is that FPKM is normalised to both the total read count in the sample and the length of the read itself (that's the kilobase of transcript part). For our downstream analysis, we pick FPKM_usntranded for our downstream analysis. The FPKM_uq differs from normal FPKM that it only takes uniquely mapped reads into account. This would be a better way to do it, although the differences are relatively small from my anecdotal experience.

## Matching CNV and Transcriptome

We match the CNV and transcriptome of different samples by looking at the manifest for downloading each. After creating a GDC query for downloading, we get the clinical information of the patient and their unique barcode identifier. We then filter out samples if they don't have all these properties:

1.  Transcriptome of tumour (primary or metastatic, user input dependant)
2.  Only 1 transcriptomics file for that tumour
3.  CNV of tumour (primary or metastatic)

This means that if a tumour has multiple transcriptome files, or missing either the transcriptome or CNV files we do not use it for downstream analysis and plots.

## Outputs generated

For the sake of reporting, at the end of the analysis pipeline a folder will be made (named after what RUN_NAME you put in the config) containing *at least* the following files:

1.  config.env used for that run
2.  data_filtered.Rds
3.  processed_data.csv
4.  plots folder with PDFs of:
    1.  Gene expression density plot, stratified by aneuploidy (low 30%, middle 40% and top 30%)
    2.  Gene expression boxplot with statistics between the aneuploidy groups
    3.  Correlation between gene expression and aneuploidy

If you also included a second gene (GENE_2 in the config) you'll also get:

1.  All the above plots for the second gene,
2.  Correlation between your two genes.

These plots can be expanded if wanted - if you have suggestions get in touch with me (Alex) and I'll see what can be done. Think you found a mistake in this README? Include the word "pindakaas" in your message to me so I know that you read it front to back. Cheers.
