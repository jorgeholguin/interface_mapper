import pandas as pd

df_samples = pd.read_csv('data/proteins.tsv', sep = '\t')
sample_names = list(df_samples['Gene_name'])


rule all:
    input:
        'figures/global_analysis.png',
        'figures/drivers_protein_specific.png',

rule pdb_ids:
    input:
        'data/proteins.tsv'
        
    output:
        'data/proteins_pdb.tsv'
        
    script:
        'scripts/get_pdb_ids.py'
        
rule pdb_files:
    input: 
        'data/proteins_pdb.tsv'
        
    output:
        directory(expand('data/structures/{protein}', protein = sample_names))
        
    script:
        'scripts/get_pdb_files.py'
        
rule best_pdb_files:
    input: 
        'data/proteins_pdb.tsv',
        expand('data/structures/{protein}', protein = sample_names)
        
    output:
        'data/proteins_pdb_best.tsv'
        
    script:
        'scripts/best_pdb.py'
        
rule interface_residues:
    input:
        'data/proteins_pdb_best.tsv',
        
    output:
        'data/proteins_interface.tsv'
        
    script:
        'scripts/get_interface_all.py'
        
rule map_mutations:
    input:
        'data/proteins_interface.tsv',
        'data/mutations/cmc_export.tsv'
        
    output:
        'data/enrichment_analysis/proteins_interface_drivers_norep.tsv',
        'data/enrichment_analysis/proteins_interface_drivers_rep.tsv',
        
    script:
        'scripts/map_mutations_to_interface.py'
        
rule analysis:
    input:
        'data/enrichment_analysis/proteins_interface_drivers_norep.tsv',
        'data/enrichment_analysis/proteins_interface_drivers_rep.tsv',
    
    output:
        'figures/global_analysis.png',
        'figures/drivers_protein_specific.png',
    
    log:
        # optional path to the processed notebook
        notebook="logs/notebooks/results.ipynb"
    
    notebook:
        "notebooks/results_template.py.ipynb"