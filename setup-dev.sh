#!/bin/bash

python3 ./setup.py egg_info
pip install -r ./sthreepo.egg-info/requires.txt
