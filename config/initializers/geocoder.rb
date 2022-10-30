Geocoder.configure(
  # Geocoding options
  timeout: 15,                  # geocoding service timeout (secs)
  lookup: :google,              # name of geocoding service (symbol)
  language: :en,                # ISO-639 language code
  use_https: true,              # use HTTPS for lookup requests? (if supported)
  bounds: [[49.860538172861155, -6.2023046951665375], [61.12159479058175, 0.6450787158853796]],
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)

  api_key: ENV['GOOGLEMAPS_GEOCODING_API_KEY'],
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #keys)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and TimeoutError
  always_raise: :all,

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
)
