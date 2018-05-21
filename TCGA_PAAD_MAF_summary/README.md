## TCGA PAAD cohort MAF summary

Example of *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/summariseMAFs.R)* output files for TCGA PAAD ( <img src="../Figures/flag-of-United-States-of-America.png" width="2.5%"> ) cohort. This example shows one sample with extremely high mutation burden. The *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/summariseMAFs.R)* script was re-ran after removing the problematic sample and the outputs were compared.

---
QUESTION: Should we **REMOVE this sample** before combining all MAF files **?**

---

#### MAF summary plots for all samples

<br/>

<img src="Figures/MAF_summary_TCGA-PAAD.jpg" width="45%"> &nbsp;&nbsp;&nbsp; <img src="Figures/Oncoplot_TCGA-PAAD.jpg" width="45%">

<br/><br/>

####  ...and after removing problematic sample

<img src="Figures/MAF_summary_TCGA-PAAD_clean.jpg" width="45%"> &nbsp;&nbsp;&nbsp; <img src="Figures/Oncoplot_TCGA-PAAD_clean.jpg" width="45%">

>The variants per sample plot and oncoplot within the *[MAF_summary_TCGA-PAAD.pdf](https://github.com/umccr/MAF-summary/tree/master/TCGA_PAAD_MAF_summary/MAF_summary_TCGA-PAAD.pdf)* file indicates that one sample has extremely high mutation burden compared to other samples within this cohort (the stacked bar-plots in the top panel). The *TCGA-PAAD* tab in the [MAF_sample_summary.xlsx](https://github.com/umccr/MAF-summary/blob/master/TCGA_PAAD_MAF_summary/MAF_sample_summary.xlsx) spreadsheet shows that sample ***TCGA-IB-7651-01A-11D-2154-08*** has 14,776 variants, which is ~100 times more than the second most mutated patient in that cohort. After removing this sample from the MAF file the variants distribution is more uniform across remaining samples (bottom panel).
<br />\* For plots description see [MAF summary plot](https://github.com/umccr/MAF-summary/tree/master/ICGC_PACA-CA_MAF_summary#maf-summary-plot) and [Oncoplot](https://github.com/umccr/MAF-summary/tree/master/ICGC_PACA-CA_MAF_summary#oncoplot) sections.


<br />


#### MAF summary table for all samples and after removing the problematic sample

<table>
  <tr>
    <td>Variant type</td>
    <td colspan="2">All samples <br/> <a href="https://github.com/umccr/MAF-summary/tree/master/TCGA_PAAD_MAF_summary/MAF_sample_summary.xlsx">MAF_sample_summary.xlsx</a></td>
    <td colspan="2">Without problematic sample <br/> <a href="https://github.com/umccr/MAF-summary/tree/master/TCGA_PAAD_MAF_summary/MAF_summary_TCGA-PAAD_clean.xlsx">MAF_summary_TCGA-PAAD_clean.xlsx</a></td>
    <td>Problematic sample</td>
  </tr>
  <tr>
    <td> </td>
    <td>Count</td>
    <td>Mean</td>
    <td>Count</td>
    <td>Mean</td>
    <td>Count</td>
  </tr>
  <tr>
    <td>Frame_Shift_Del</td>
    <td>123</td>
    <td>0.86</td>
    <td>120</td>
    <td>0.85</td>
    <td>3</td>
  </tr>
  <tr>
    <td>Frame_Shift_Ins</td>
    <td>51</td>
    <td>0.36</td>
    <td>48</td>
    <td>0.34</td>
    <td>3</td>
  </tr>
  <tr>
    <td>In_Frame_Del</td>
    <td>34</td>
    <td>0.24</td>
    <td>34</td>
    <td>0.24</td>
    <td>0</td>
  </tr>
  <tr>
    <td>In_Frame_Ins</td>
    <td>4</td>
    <td>0.03</td>
    <td>4</td>
    <td>0.03</td>
    <td>0</td>
  </tr>
  <tr>
    <td>Missense_Mutation</td>
    <td>19,610</td>
    <td>137.13</td>
    <td>6,418</td>
    <td>45.2</td>
    <td><b>13,192</b></td>
  </tr>
  <tr>
    <td>Nonsense_Mutation</td>
    <td>1,284</td>
    <td>8.98</td>
    <td>434</td>
    <td>3.06</td>
    <td><b>850</b></td>
  </tr>
  <tr>
    <td>Nonstop_Mutation</td>
    <td>6</td>
    <td>0.04</td>
    <td>3</td>
    <td>0.02</td>
    <td>3</td>
  </tr>
  <tr>
    <td>Splice_Site</td>
    <td>963</td>
    <td>6.73</td>
    <td>276</td>
    <td>1.94</td>
    <td><b>687</b></td>
  </tr>
  <tr>
    <td>Translation_Start_Site</td>
    <td>50</td>
    <td>0.35</td>
    <td>12</td>
    <td>0.09</td>
    <td>38</td>
  </tr>
  <tr>
    <td><b>Total</b></td>
    <td><b>22,125</b></td>
    <td><b>154.72</b></td>
    <td><b>7,349</b></td>
    <td><b>51.75</b></td>
    <td><b>14,776</b></td>
  </tr>
</table>

<br />
