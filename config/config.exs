[pooler: [pools: [
  [ name: :riaklocal,
    group: :riak,
    max_count: 10,
    init_count: 5,
    start_mfa: {Riex.Connection, :start_link, []}
  ]
]]]
