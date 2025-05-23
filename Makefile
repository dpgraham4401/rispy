.PHONY: clean lint format test coverage build publish

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

VERSION := $(shell python -c "import rispy; print(rispy.__version__)")

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean:  ## Remove all build, test and Python artifacts
	# build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +
	# test artifacts
	rm -fr htmlcov/
	# python artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

lint:  ## Check python formatting issues
	@ruff format . --check && ruff .

format:  ## Fix python formatting issues where possible
	@ruff format . && ruff . --fix --show-fixes

test:  ## Run unit test suite
	@py.test --benchmark-skip

bench:  ## Run benchmark test suite
	@py.test --benchmark-only

coverage:  ## Run coverage and create html report
	coverage run -m pytest --benchmark-skip
	coverage html -d coverage_html

build: clean ## builds source and wheel package
	flit build
	ls -l dist

publish: ## package and upload a release
	flit publish
	git tag $(VERSION)
	git push --tags
