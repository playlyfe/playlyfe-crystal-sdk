require "./helper"

describe Playlyfe do
  it "creates a client" do
    pl = Playlyfe.new(
      client_id: "Zjc0MWU0N2MtODkzNS00ZWNmLWEwNmYtY2M1MGMxNGQ1YmQ4",
      client_secret: "YzllYTE5NDQtNDMwMC00YTdkLWFiM2MtNTg0Y2ZkOThjYTZkMGIyNWVlNDAtNGJiMC0xMWU0LWI2NGEtYjlmMmFkYTdjOTI3",
      type: "client",
      version: "v1",
      debug: true
    )
    puts pl.get("/runtime/player", { :player_id => "student1" })
    puts pl.get("/admin/players")
  end
end
