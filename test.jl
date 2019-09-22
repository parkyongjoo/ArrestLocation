using CSV
using HTTP
using JSON
using DataFrames

#tbi = CSV.read("../data/TBI_2011_2016hosp.utf8.csv", delim = "\t", header = 1)
arrest = CSV.read("data/arrest.utf8.cleared.csv", delim = "\t", header = 1)

#r = HTTP.request("GET", "https://dapi.kakao.com/v2/local/search/address.json"; 
#    headers = 
#        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
#    query = Dict("query" => "경남 창원시 성산구 성주동  삼정자로 11"))

#=
j = String(r.body)
p = JSON.parse(j)

x = p["documents"][1]["x"]
y = p["documents"][1]["y"]
=#

kn = arrest[arrest[!, :sido] .== "경남", :]
juso = kn[!,[:ems_sn,:address_happen_si,:address_happen_gu,:address_happen_dong,
    :address_happen_bunji,:address_happen_else]]

function misstext(text)
    if ismissing(text); return ""; else return text ;end
end

d = DataFrame(serial = String[], juso = String[], x = String[], y = String[])

for i in 1:size(juso, 1)
    s = string(juso[i,1])
    a = misstext(juso[i,2])*" "*misstext(juso[i,3])*" "*misstext(juso[i,4])*
        " "*misstext(juso[i,5])
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
            Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
        query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    if p["meta"]["total_count"] == 0
        a = misstext(juso[i,2])*" "*misstext(juso[i,3])*" "*misstext(juso[i,4])
        r = HTTP.request("GET", 
            "https://dapi.kakao.com/v2/local/search/address.json"; 
            headers = 
            Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
            query = Dict("query" => a))
            j = String(r.body)
            p = JSON.parse(j)
    end
    try
        x = p["documents"][1]["x"]
        y = p["documents"][1]["y"]
        println(s," ",a," ",x," ",y)
        push!(d, [s a x y])
    catch
        x = "miss"
        y = "miss"
        println(s," ",a," ",x," ",y)
        push!(d, [s a x y])
    end

end

center = CSV.read("../data/center.csv", header = 0)
centerxy = DataFrame(x = String[], y = String[])

for i in 1:size(center, 1)
    a = center[i,:Column8]
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
        query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    try
        x = p["documents"][1]["x"]
        y = p["documents"][1]["y"]
        println(a," ",x," ",y)
        push!(centerxy, [x y])
    catch
        x = "miss"
        y = "miss"
        println(a," ",x," ",y)
        push!(centerxy, [x y])
    end

end

kncenterxy = hcat(center, centerxy)

CSV.write("kncenterxy.csv", kncenterxy)


facility = CSV.read("../data/facility.csv", header = 0)
facilityxy = DataFrame(x = String[], y = String[])

for i in 1:size(facility, 1)
    a = facility[i,:Column8]
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
        query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    try
        x = p["documents"][1]["x"]
        y = p["documents"][1]["y"]
        println(a," ",x," ",y)
        push!(facilityxy, [x y])
    catch
        x = "miss"
        y = "miss"
        println(a," ",x," ",y)
        push!(facilityxy, [x y])
    end

end

knfacilityxy = hcat(facility, facilityxy)

CSV.write("knfacilityxy.csv", knfacilityxy)

