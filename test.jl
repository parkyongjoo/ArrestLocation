using CSV
using HTTP
using JSON

tbi = CSV.read("data/TBI_2011_2016hosp.utf8.csv", delim = "\t", header = 1)
arrest = CSV.read("data/arrest.utf8.cleared.csv", delim = "\t", header = 1)

r = HTTP.request("GET", "https://dapi.kakao.com/v2/local/search/address.json"; 
    headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
    query = Dict("query" => "경남 창원시 성산구 성주동  삼정자로 11"))

j = String(r.body)
p = JSON.parse(j)
