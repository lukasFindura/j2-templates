### Dependencies

```bash
pipx install j2cli --pip-args='setuptools<81'
```

### If needed

```bash
ln -s `pwd`/.template.sh $HOME/.local/bin/j2template
export PYTHONWARNINGS="ignore:pkg_resources is deprecated:UserWarning"
```
