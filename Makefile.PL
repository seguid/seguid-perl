use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'SEGUID',
    VERSION_FROM     => 'lib/SEGUID.pm',
    AUTHOR           => 'Gyorgy Babnigg <gbabnigg@gmail.com>',
    ABSTRACT         => 'Generate SEGUID (Sequence Global Unique IDentifier)',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => '5.010',
    PREREQ_PM        => {
        'Digest::SHA'   => 0,
        'MIME::Base64'  => 0,
        'Carp'          => 0,
        'Getopt::Long'  => 0,
        'Pod::Usage'    => 0,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/gyorgy5635/SEGUID.git',
                web  => 'https://github.com/gyorgy5635/SEGUID',
            },
            bugtracker => {
                web => 'https://github.com/gyorgy5635/SEGUID/issues',
            },
        },
    },
    EXE_FILES => ['script/seguid'],  # Instead of bin/seguid
);
