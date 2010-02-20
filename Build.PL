use Module::Build;
my $build = Module::Build->new(
    module_name          => 'Bio::Chado::Schema',
    dist_name            => 'Bio-Chado-Schema',
    dist_abstract        => 'standard DBIx::Class layer for the Chado schema',
    license              => 'perl',
    create_makefile_pl   => 'passthrough',
    recursive_test_files => 1,
    create_readme        => 1,
    create_license       => 1,
    meta_merge           => {
        resources =>
          { repository => 'http://github.com/rbuels/Bio-Chado-Schema', },
    },
    build_requires => {
        'Test::Exception' => '0.27',
        'Test::Warn'      => 0,
        'Test::More'      => 0,
    },
    requires       => {
        'perl' => '5.8.0',

        # right now, we have to depend on whole bioperl, like this
        'Bio::Root::Version' => '1.005002',

        # keep SPECIFIC bioperl dependencies here, for when bioperl
        # is in smaller, versioned chunks.
        # 'Bio::PrimarySeq' => '1.5.2',

        'Carp'                 => '1.08',
        'Carp::Clan'           => '6.00',
        'DBIx::Class'          => '0.08111',
        'Module::Load'         => 0,
    },
);
$build->create_build_script;
