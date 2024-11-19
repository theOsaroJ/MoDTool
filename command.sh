#!/bin/bash


#In no particular order but use based on intuition which preprocessing data --> training model (make sure to put targets.csv in format as in example which is the y of the training molecules in ~./data) --
# --> computing descriptors for new molecules after running python modify.py and moving file to right place ( see creating_xyz_files) for more details --
# --> predicting properties of new molecule.

### --------------------------------- preprocessing training xyz into descriptors gotten from RDKit ------------------------------------- ###
python3 opac3/scripts/preprocess_data.py \
    --input-dir data/training_xyz_files/ \
    --targets-file data/targets.csv \
    --output-descriptors data/descriptors.csv

### ---------------------------------- train a vae model ------------------------------------ ###
python3 opac3/scripts/train_model.py \
    --descriptors-file data/descriptors.csv \
    --targets-file data/targets.csv \
    --model-output models/trained_model.pth \
    --epochs 200 \
    --validation-size 0.2 \
    --learning-rate 0.01 \
    --batch-size 64 \
    --hidden-dim 512 \
    --weight-decay 1e-4

## ------------------------------------- get new descriptors of test molecules in right xyz format ---------------------------##
python3 create_xyz_files/modify.py test.xyz test_modified.xyz
cp create_xyz_files/test_modified.xyz data/testing_xyz_files

## --------------------------------------- convert the test xyz to the descriptors recognized by model------------------------##
python3 opac3/scripts/compute_descriptors.py \
    --input-dir data/testing_xyz_files/ \
    --output-descriptors data/new_descriptors.csv

## ------------------------------------------ make predictions of the new molecules ----------------------------------------- ##
python3 opac3/scripts/predict_properties.py \
    --model-file models/trained_model.pth \
    --descriptors-file data/new_descriptors.csv \
    --predictions-output data/predictions.csv

##
