require "./helper"

describe Playlyfe do

  it "creates an invalid client" do
    expect_raises(PlaylyfeException) do
      pl = Playlyfe.new(
        client_id: "Zjc",
        client_secret: "Yz",
        type: "client",
        version: "v2",
        debug: true
      )
      pl.get("/runtime/player", { :player_id => "student1" })
    end
  end

  it "should test staging" do
    pl = Playlyfe.new(
      client_id: "Zjc0MWU0N2MtODkzNS00ZWNmLWEwNmYtY2M1MGMxNGQ1YmQ4",
      client_secret: "YzllYTE5NDQtNDMwMC00YTdkLWFiM2MtNTg0Y2ZkOThjYTZkMGIyNWVlNDAtNGJiMC0xMWU0LWI2NGEtYjlmMmFkYTdjOTI3",
      type: "client",
      version: "v1",
      debug: true
    )
    expect_raises(PlaylyfeException) do
      pl.get("/gege", { player_id: "student1" })
    end
    players = pl.api("GET", "/players", { player_id: "student1", limit: 1 }, {} of String => String)
    players["data"].not_nil!
    (players["data"] as Array).not_nil!

    expect_raises(PlaylyfeException) do
      pl.get("/player")
    end

    player_id = "student1"
    player = pl.get("/player", { player_id: player_id } )
    player["id"].should eq("student1")
    player["alias"].should eq("Student1")
    player["enabled"].should be_true

    # pl.get("/definitions/processes", { player_id: player_id } )
    # pl.get("/definitions/teams", { player_id: player_id } )
    pl.get("/processes", { player_id: player_id } )
    pl.get("/teams", { player_id: player_id } )

    processes = pl.get("/processes", { player_id: "student1", limit: 1, skip: 4 })
    ((processes["data"]as Array)[0] as Hash)["definition"].should eq("module1")
    (processes["data"] as Array).length.should eq(1)

    new_process = pl.post("/definitions/processes/module1", { player_id: player_id })
    new_process["definition"].should eq("module1")
    new_process["state"].should eq("ACTIVE")

    patched_process = pl.patch(
      "/processes/#{new_process["id"]}",
      { player_id: player_id },
      { name: "patched_process", access: "PUBLIC" }
    )
    patched_process["name"].should eq("patched_process")
    patched_process["access"].should eq("PUBLIC")

    deleted_process = pl.delete("/processes/#{new_process["id"]}", { player_id: player_id })
    deleted_process["message"].not_nil!

    raw_data = pl.get_raw("/player", { player_id: player_id })
    typeof(raw_data as String).should eq(String)
  end


end

 def test_init_staging_v2
    pl = Playlyfe.new(
      client_id: "Zjc0MWU0N2MtODkzNS00ZWNmLWEwNmYtY2M1MGMxNGQ1YmQ4",
      client_secret: "YzllYTE5NDQtNDMwMC00YTdkLWFiM2MtNTg0Y2ZkOThjYTZkMGIyNWVlNDAtNGJiMC0xMWU0LWI2NGEtYjlmMmFkYTdjOTI3",
      type: "client",
      version: "v2",
      debug: true
    )

    players = pl.api("GET", "/runtime/players", { player_id: "student1", limit: 1 })
    players["data"].not_nil!
    (players["data"] as Array).not_nil!

    expect_raises(PlaylyfeException) do
      pl.get("/runtime/player")
    end

    player_id = "student1"
    player = pl.get("/runtime/player", { player_id: player_id } )
    player["id"].should eq("student1")
    player["alias"].should eq("Student1")
    player["enabled"].should be_true

    # pl.get("/runtime/definitions/processes", { player_id: player_id } )
    # pl.get("/runtime/definitions/teams", { player_id: player_id } )
    pl.get("/runtime/processes", { player_id: player_id } )
    pl.get("/runtime/teams", { player_id: player_id } )

    processes = pl.get("/runtime/processes", { player_id: "student1", limit: 1, skip: 4 })
    ((processes["data"]as Array)[0] as Hash)["definition"].should eq("module1")
    (processes["data"] as Array).length.should eq(1)


    new_process = pl.post("/runtime/processes", { player_id: player_id }, { definition: "module1" })
    new_process["definition"].should eq("module1")
    new_process["state"].should eq("ACTIVE")

    patched_process = pl.patch(
      "/runtime/processes/#{new_process["id"]}",
      { player_id: player_id },
      { name: "patched_process", access: "PUBLIC" }
    )
    patched_process["name"].should eq("patched_process")
    patched_process["access"].should eq("PUBLIC")

    deleted_process = pl.delete("/runtime/processes/#{new_process["id"]}", { player_id: player_id })
    deleted_process["message"].not_nil!

    #data = pl.put("/players/#{player_id}/reset", { player_id: player_id })
    #puts data

    raw_data = pl.get_raw("/runtime/player", { player_id: player_id })
    typeof(raw_data as String).should eq(String)
  end

 #  def test_store
 #    access_token = nil
 #    pl = Playlyfe.new(
 #      version: "v1",
 #      client_id: "Zjc0MWU0N2MtODkzNS00ZWNmLWEwNmYtY2M1MGMxNGQ1YmQ4",
 #      client_secret: "YzllYTE5NDQtNDMwMC00YTdkLWFiM2MtNTg0Y2ZkOThjYTZkMGIyNWVlNDAtNGJiMC0xMWU0LWI2NGEtYjlmMmFkYTdjOTI3",
 #      type: "client",
 #      store: lambda { |token| access_token = token },
 #      load: lambda { return access_token }
 #    )
 #    players = pl.get("/players", { player_id: "student1", limit: 1 })
 #    assert_not_nil players["data"]
 #    assert_not_nil players["data"][0]
 #  end

 #  def test_jwt
 #    token = Playlyfe.createJWT(
 #      client_id: "MWYwZGYzNTYtZGIxNy00OGM5LWExZGMtZjBjYTFiN2QxMTlh",
 #      client_secret: "NmM2YTcxOGYtNGE2ZC00ZDdhLTkyODQtYTIwZTE4ZDc5YWNjNWFiNzBiYjAtZmZiMC0xMWU0LTg5YzctYzc5NWNiNzA1Y2E4",
 #      player_id: "student1",
 #      scopes: ["player.runtime.read"],
 #      expires: 30
 #    )
 #    puts token
 #  end
