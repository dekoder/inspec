require_relative "./primitives"

# We disable this for the sake of legibility
# rubocop:disable Layout/AlignHash

# These type occur only when running "inspec exec --reporter json <file>".

module Schema
  module ExecJson
    # Represents a control produced
    CONTROL = SchemaType.new("Exec JSON Control", {
      "additionalProperties" => false,
      "required" => %w{id title desc descriptions impact refs tags code source_location results},
      "properties" => {
        "id"                => STRING,
        "title"             => { "type" => %w{string null} }, # Nullable string
        "desc"              => { "type" => %w{string null} },
        "descriptions"      => Schema.array(CONTROL_DESCRIPTION.ref),
        "impact"            => IMPACT,
        "refs"              => Schema.array(REFERENCE.ref),
        "tags"              => TAGS,
        "code"              => STRING,
        "source_location"   => SOURCE_LOCATION.ref,
        "results"           => Schema.array(CONTROL_RESULT.ref),
      },
    }, [CONTROL_DESCRIPTION, REFERENCE, SOURCE_LOCATION, CONTROL_RESULT])

    # Based loosely on https://www.inspec.io/docs/reference/profiles/ as of July 3, 2019
    # However, concessions were made to the reality of current reporters, specifically
    # with how description is omitted and version/inspec_version aren't as advertised online
    PROFILE = SchemaType.new("Exec JSON Profile", {
      "additionalProperties" => false,
      "required" => %w{name sha256 supports attributes groups controls status},
      # Name is mandatory in inspec.yml.
      # supports, controls, groups, and attributes are always present, even if empty
      # sha256, status, skip_message
      "properties" => {
        # These are provided in inspec.yml
        "name"              => STRING,
        "title"             => STRING,
        "maintainer"        => STRING,
        "copyright"         => STRING,
        "copyright_email"   => STRING,
        "license"           => STRING,
        "summary"           => STRING,
        "version"           => STRING,
        "supports"          => Schema.array(SUPPORT.ref),
        # NOTE: In this version of the schema we do not include
        # the "description" or the "inspec_version" that are suggested by the docs

        # These are generated at runtime, and all except skip_message are guaranteed
        "sha256"            => STRING,
        "status"            => STRING,
        "skip_message"      => STRING, # If skipped, why
        "controls"          => Schema.array(CONTROL.ref),
        "groups"            => Schema.array(CONTROL_GROUP.ref),
        "attributes"        => Schema.array(INPUT), # TODO: rename to inputs, refs #3802
      },
    }, [CONTROL, CONTROL_GROUP, SUPPORT])

    # Result of exec json. Top level value
    OUTPUT = SchemaType.new("Exec JSON Output", {
      "additionalProperties" => false,
      "required" => %w{platform profiles statistics version},
      "properties" => {
        "platform"      => PLATFORM.ref,
        "profiles"      => Schema.array(PROFILE.ref),
        "statistics"    => STATISTICS.ref,
        "version"       => STRING,
      },
    }, [PLATFORM, PROFILE, STATISTICS])
  end
end
