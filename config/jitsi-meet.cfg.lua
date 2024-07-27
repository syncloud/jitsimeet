admins = {
    "jigasi@auth.{{ .Domain }}",
    "jibri@auth.{{ .Domain }}",
    "focus@auth.{{ .Domain }}",
    "jvb@auth.{{ .Domain }}"
}

unlimited_jids = {
    "focus@auth.{{ .Domain }}",
    "jvb@auth.{{ .Domain }}"
}

plugin_paths = { "{{ .AppDir }}/prosody/prosody-plugins/", "{{ .AppDir }}/prosody/prosody-plugins-custom", "{{ .AppDir }}/prosody/prosody-plugins-contrib" }

muc_mapper_domain_base = "{{ .Domain }}";
muc_mapper_domain_prefix = "muc";

http_default_host = "{{ .Domain }}"

consider_bosh_secure = true;
consider_websocket_secure = true;

smacks_max_unacked_stanzas = 5;
smacks_hibernation_time = 60;
smacks_max_old_sessions = 1;

VirtualHost "{{ .Domain }}"

    authentication = "jitsi-anonymous"

    ssl = {
        key = "{{ .DataDir }}/data/{{ .Domain }}.key";
        certificate = "{{ .DataDir }}/data/{{ .Domain }}.crt";
    }
    modules_enabled = {
        "bosh";

        "websocket";
        "smacks"; -- XEP-0198: Stream Management

        "speakerstats";
        "conference_duration";
        "room_metadata";

        "end_conference";



        "muc_lobby_rooms";


        "muc_breakout_rooms";


        "av_moderation";





    }

    main_muc = "muc.{{ .Domain }}"
    room_metadata_component = "metadata.{{ .Domain }}"

    lobby_muc = "lobby.{{ .Domain }}"






    breakout_rooms_muc = "breakout.{{ .Domain }}"


    speakerstats_component = "speakerstats.{{ .Domain }}"
    conference_duration_component = "conferenceduration.{{ .Domain }}"


    end_conference_component = "endconference.{{ .Domain }}"



    av_moderation_component = "avmoderation.{{ .Domain }}"


    c2s_require_encryption = true





VirtualHost "auth.{{ .Domain }}"
    ssl = {
        key = "{{ .DataDir }}/data/auth.{{ .Domain }}.key";
        certificate = "{{ .DataDir }}/data/auth.{{ .Domain }}.crt";
    }
    modules_enabled = {
        "limits_exception";
    }
    authentication = "internal_hashed"



Component "internal-muc.{{ .Domain }}" "muc"
    storage = "memory"
    modules_enabled = {
        }
    restrict_room_creation = true
    muc_filter_whitelist="auth.{{ .Domain }}"
    muc_room_locking = false
    muc_room_default_public_jids = true
    muc_room_cache_size = 1000
    muc_tombstones = false
    muc_room_allow_persistent = false

Component "muc.{{ .Domain }}" "muc"
    restrict_room_creation = true
    storage = "memory"
    modules_enabled = {
        "muc_meeting_id";

        "polls";
        "muc_domain_mapper";

        "muc_password_whitelist";
    }

    -- The size of the cache that saves state for IP addresses
    rate_limit_cache_size = 10000;

    muc_room_cache_size = 10000
    muc_room_locking = false
    muc_room_default_public_jids = true

    muc_password_whitelist = {
        "focus@auth.{{ .Domain }}";
    }
    muc_tombstones = false
    muc_room_allow_persistent = false

Component "focus.{{ .Domain }}" "client_proxy"
    target_address = "focus@auth.{{ .Domain }}"

Component "speakerstats.{{ .Domain }}" "speakerstats_component"
    muc_component = "muc.{{ .Domain }}"

Component "conferenceduration.{{ .Domain }}" "conference_duration_component"
    muc_component = "muc.{{ .Domain }}"


Component "endconference.{{ .Domain }}" "end_conference"
    muc_component = "muc.{{ .Domain }}"



Component "avmoderation.{{ .Domain }}" "av_moderation_component"
    muc_component = "muc.{{ .Domain }}"



Component "lobby.{{ .Domain }}" "muc"
    storage = "memory"
    restrict_room_creation = true
    muc_tombstones = false
    muc_room_allow_persistent = false
    muc_room_cache_size = 10000
    muc_room_locking = false
    muc_room_default_public_jids = true
    modules_enabled = {
        }




Component "breakout.{{ .Domain }}" "muc"
    storage = "memory"
    restrict_room_creation = true
    muc_room_cache_size = 10000
    muc_room_locking = false
    muc_room_default_public_jids = true
    muc_tombstones = false
    muc_room_allow_persistent = false
    modules_enabled = {
        "muc_meeting_id";
        "polls";
        }


Component "metadata.{{ .Domain }}" "room_metadata_component"
    muc_component = "muc.{{ .Domain }}"
    breakout_rooms_component = "breakout.{{ .Domain }}"
