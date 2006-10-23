module Ramaze
  STATUS_CODE = {
    # 1xx Informational (Request received, continuing process.)

    :continue                         => 100,
    :switching_protocols              => 101,

    # 2xx Success (The action was successfully received, understood, and accepted.)

    :ok                               => 200,
    :created                          => 201,
    :accepted                         => 202,
    :non_authorative_information      => 203,
    :no_content                       => 204,
    :resent_content                   => 205,
    :partial_content                  => 206,
    :multi_status                     => 207,

    # 3xx Redirection (The client must take additional action to complete the request.)

    :multiple_choices                 => 300,
    :moved_permamently                => 301,
    :moved_temporarily                => 302,
    :found                            => 302,
    :see_other                        => 303,
    :not_modified                     => 304,
    :use_proxy                        => 305,
    :switch_proxy                     => 306,
    :temporary_redirect               => 307,

    # 4xx Client Error (The request contains bad syntax or cannot be fulfilled.)

    :bad_request                      => 400,
    :unauthorized                     => 401,
    :payment_required                 => 402,
    :forbidden                        => 403,
    :not_found                        => 404,
    :method_not_allowed               => 405,
    :not_aceptable                    => 406,
    :proxy_authentication_required    => 407,
    :request_timeout                  => 408,
    :conflict                         => 409,
    :gone                             => 410,
    :length_required                  => 411,
    :precondition_failed              => 412,
    :request_entity_too_large         => 413,
    :request_uri_too_long             => 414,
    :unsupported_media_type           => 415,
    :requested_range_not_satisfiable  => 416,
    :expectation_failed               => 417,
    :retry_with                       => 449,

    # 5xx Server Error (The server failed to fulfill an apparently valid request.)

    :internal_server_error            => 500,
    :not_implemented                  => 501,
    :bad_gateway                      => 502,
    :service_unavailable              => 503,
    :gateway_timeout                  => 504,
    :http_version_not_supported       => 505,
    :bandwidth_limit_exceeded         => 509, # (not official)
  }
end
