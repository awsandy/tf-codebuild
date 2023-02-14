cd python
pip install --target . requests
zip -r layer.zip ../python
aws s3 cp layer.zip s3://event-engine-eu-west-1/layers-python/layer.zip
