describe ImportNewReleasesJob, type: :job do
  it 'triggers the AllNewGithubReleasesImporter to perform imports' do
    importer = instance_double(AllNewGithubReleasesImporter)
    expect(AllNewGithubReleasesImporter).to receive(:new).and_return(importer)
    expect(importer).to receive(:perform).once

    ImportNewReleasesJob.perform_now
  end
end
