.PHONY: clean data lint requirements 

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = [OPTIONAL] your-bucket-for-syncing-data (do not include 's3://')
PROJECT_NAME = naep-challenge
VENV_NAME:=venv
JUPYTER=${VENV_NAME}/bin/jupyter
JUPYTER_VENV_NAME=venv
JUPYTER_PORT=8888
PYTHON_INTERPRETER = ${VENV_NAME}/bin/python3

# Colors for echos
ccend = $(shell tput sgr0)
ccbold = $(shell tput bold)
ccgreen = $(shell tput setaf 2)
ccso = $(shell tput smso)

#################################################################################
# COMMANDS                                                                      #
#################################################################################

####################
# VIRTUAL ENVIRONMENT
####################

isvirtualenv:
	@if [ -z "$(VENV_NAME)" ]; then echo "ERROR: Not in a virtualenv." 1>&2; exit 1; fi

## Creates a virtual environment
venv:
	@echo "$(ccso)--> Install and setup venv $(ccend)"
	python3 -m venv $(VENV_NAME)

## Clean venv
clean_venv:
	@echo ""
	@echo "$(ccso)--> Removing virtual environment $(ccend)"
	rm -rf $(VENV_NAME)

######################
# Notebooks
######################

## Clean output of jupyter notebooks
clean_nb_%:
	$(JUPYTER) nbconvert --ClearOutputPreprocessor.enabled=True --inplace notebooks/$*.ipynb

## Clean output of all jupyter notebooks
cleanall_nb: $(patsubst notebooks/%.ipynb,clean_nb_%,$(wildcard notebooks/*.ipynb))

## Install a Jupyter iPython kernel using our virtual environment
ipykernel: ##@main >> install a Jupyter iPython kernel using our virtual environment
	@echo ""
	@echo "$(ccso)--> Install ipykernel to be used by jupyter notebooks $(ccend)"
	$(PYTHON_INTERPRETER) -m pip install ipykernel jupyter jupyter_contrib_nbextensions jupyter_nbextensions_configurator
	$(PYTHON_INTERPRETER) -m ipykernel install \
                                        --user \
                                        --name=$(VENV_NAME) \
                                        --display-name=$(JUPYTER_VENV_NAME)
	$(PYTHON_INTERPRETER) -m jupyter nbextension enable --py widgetsnbextension --sys-prefix

## Starts a Jupyter notebook
jupyter: ipykernel
	@echo ""
	@echo "$(ccso)--> Running jupyter notebook on port $(JUPYTER_PORT) $(ccend)"
	$(JUPYTER) notebook --port $(JUPYTER_PORT)


## Install Python Dependencies
requirements: isvirtualenv test_environment
	@echo "$(ccso)--> Updating packages $(ccend)"
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

## Make Dataset
data:
	$(PYTHON_INTERPRETER) src/data/make_dataset.py data/raw data/interim

features:
	$(PYTHON_INTERPRETER) src/features/build_features.py data/interim data/processed

evaluate-specific:
	$(PYTHON_INTERPRETER) src/models/evaluate.py 1

evaluate-generic:
	$(PYTHON_INTERPRETER) src/models/evaluate.py 2

predict-specific:
	$(PYTHON_INTERPRETER) src/models/predict_model.py models/model.pkl data/processed/specific_test.csv reports/predictions-specific.csv Score1

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint: venv
	$(PYTHON_INTERPRETER) -m flake8 src

## Set up python interpreter environment

## Test python environment is setup correctly
test_environment:
	$(PYTHON_INTERPRETER) test_environment.py

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
