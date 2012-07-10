module S3Helpers

  def s3_credentials
    return @s3_credentials if @s3_credentials
    content = File.open('./spec/support/s3_credentials.yml').read
    @test_s3_credentials = YAML.load(content)
  end

  def use_test_s3_credentials
    OKCMOA::S3.stubs(:access_key_id).returns(s3_credentials['service_config']['access_key_id'])
    OKCMOA::S3.stubs(:secret_access_key).returns(s3_credentials['service_config']['secret_access_key'])
    OKCMOA::S3.stubs(:bucket_name).returns(s3_credentials['bucket_name'])
  end

end

MiniTest::Spec.send :include, S3Helpers
