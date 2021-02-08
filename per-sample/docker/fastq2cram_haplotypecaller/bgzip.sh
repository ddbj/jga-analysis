#!/bin/bash

ln -s $VCF .
bgzip -@ $NUM_THREADS $(basename $VCF)
