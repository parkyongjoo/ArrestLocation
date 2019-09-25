using CSV
using HTTP
using JSON
using DataFrames

#tbi = CSV.read("../data/TBI_2011_2016hosp.utf8.csv", delim = "\t", header = 1)
arrest = CSV.read("../data/arrest.utf8.cleared.csv", delim = "\t", header = 1)

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



addressxy = CSV.read("addressxy.csv", header = 1)

detailkn = kn[!,[:ems_sn,:fdsn,:nhosp,:age,:sex,:address_happen_bunji,
    :address_happen_else,:address_happen_else1,:address_f,:address_f_else,
    :sx1,:disease,:injury_detail,:test]]

detailknxy = hcat(detailkn, addressxy)

CSV.write("detailknxy.csv", detailknxy)









## 부산 만들기

busan = arrest[arrest[!, :sido] .== "부산", :]

busanabs = busan[!,[:ems_sn,:fdsn,:nhosp,:age,:sex,:address_happen_si,
    :address_happen_gu,:address_happen_dong,:address_happen_bunji,
    :address_happen_else,:address_happen_else1,:address_f,
    :address_f_else,:sx1,:disease,:injury_detail,:test]]

function misstext(text)
    if ismissing(text); return ""; else return text ;end
end
    
busanxy = DataFrame(serial = String[], juso = String[],
    x = String[], y = String[])
    
for i in 1:size(busanabs, 1)
    s = string(busanabs[i,:ems_sn])
    a = misstext(busanabs[i,:address_happen_si]*" ")*
        misstext(busanabs[i,:address_happen_gu]*" ")*
        misstext(busanabs[i,:address_happen_dong]*" ")*
        misstext(busanabs[i,:address_happen_bunji])
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
    query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    if p["meta"]["total_count"] == 0
        a = misstext(busanabs[i,:address_happen_si]*" ")*
            misstext(busanabs[i,:address_happen_gu]*" ")*
            misstext(busanabs[i,:address_happen_dong])
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
            println(s,"\t",a,"\t\t",x,"\t",y)
            push!(busanxy, [s a x y])
    catch
            x = "miss"
            y = "miss"
            println(s," ",a," ",x," ",y)
            push!(busanxy, [s a x y])
    end
end

CSV.write("busanxy.csv", busanxy)

busan[!,:survtoadm] = map(x -> 
    try;    ifelse(x == 10 || x == 21 || x == 30, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch;  return missing  end,
    busan[!,:er_result]) # 살면 1 죽으면 0

busan[!,:survtodis] = map(x ->
    try;    ifelse(x == 10 || x == 20 || x == 30 || x == 31, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch; return missing end,
    busan[!,:ad_result])

busan[!,:survdisfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    busan[!,:survtodis]
)

busan[!,:survadmfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    busan[!,:survtoadm]
)

busanarrest = hcat(busanabs, busanxy, busan[!,[:survadmfinal,:survdisfinal]])
CSV.write("busanarrest.csv", busanarrest)

busansurvtoadm = busanarrest[busanarrest[!,:survadmfinal] .== 1,:]
busansurvtodis = busanarrest[busanarrest[!,:survdisfinal] .== 1,:]
CSV.write("busansurvtoadm.csv", busansurvtoadm)
CSV.write("busansurvtodis.csv", busansurvtodis)


## 울산 만들기

ulsan = arrest[arrest[!, :sido] .== "울산", :]

ulsanabs = ulsan[!,[:ems_sn,:fdsn,:nhosp,:age,:sex,:address_happen_si,
    :address_happen_gu,:address_happen_dong,:address_happen_bunji,
    :address_happen_else,:address_happen_else1,:address_f,
    :address_f_else,:sx1,:disease,:injury_detail,:test]]

function misstext(text)
    if ismissing(text); return ""; else return text ;end
end
    
ulsanxy = DataFrame(serial = String[], juso = String[],
    x = String[], y = String[])
    
for i in 1:size(ulsanabs, 1)
    s = string(ulsanabs[i,:ems_sn])
    a = misstext(ulsanabs[i,:address_happen_si]*" ")*
        misstext(ulsanabs[i,:address_happen_gu]*" ")*
        misstext(ulsanabs[i,:address_happen_dong]*" ")*
        misstext(ulsanabs[i,:address_happen_bunji])
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
    query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    if p["meta"]["total_count"] == 0
        a = misstext(ulsanabs[i,:address_happen_si]*" ")*
            misstext(ulsanabs[i,:address_happen_gu]*" ")*
            misstext(ulsanabs[i,:address_happen_dong])
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
            println(s,"\t",a,"\t\t\t",x,"\t",y)
            push!(ulsanxy, [s a x y])
    catch
            x = "miss"
            y = "miss"
            println(s," ",a," ",x," ",y)
            push!(ulsanxy, [s a x y])
    end
end

CSV.write("ulsanxy.csv", ulsanxy)

ulsan[!,:survtoadm] = map(x -> 
    try;    ifelse(x == 10 || x == 21 || x == 30, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch;  return missing  end,
    ulsan[!,:er_result]) # 살면 1 죽으면 0

ulsan[!,:survtodis] = map(x ->
    try;    ifelse(x == 10 || x == 20 || x == 30 || x == 31, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch; return missing end,
    ulsan[!,:ad_result])

ulsan[!,:survdisfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    ulsan[!,:survtodis]
)

ulsan[!,:survadmfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    ulsan[!,:survtoadm]
)

ulsanarrest = hcat(ulsanabs, ulsanxy, ulsan[!,[:survadmfinal,:survdisfinal]])
CSV.write("ulsanarrest.csv", ulsanarrest)

ulsansurvtoadm = ulsanarrest[ulsanarrest[!,:survadmfinal] .== 1,:]
ulsansurvtodis = ulsanarrest[ulsanarrest[!,:survdisfinal] .== 1,:]
CSV.write("ulsansurvtoadm.csv", ulsansurvtoadm)
CSV.write("ulsansurvtodis.csv", ulsansurvtodis)



## 경북 만들기

gb = arrest[arrest[!, :sido] .== "경북", :]

gbabs = gb[!,[:ems_sn,:fdsn,:nhosp,:age,:sex,:address_happen_si,
    :address_happen_gu,:address_happen_dong,:address_happen_bunji,
    :address_happen_else,:address_happen_else1,:address_f,
    :address_f_else,:sx1,:disease,:injury_detail,:test]]

function misstext(text)
    if ismissing(text); return ""; else return text ;end
end
    
gbxy = DataFrame(serial = String[], juso = String[],
    x = String[], y = String[])
    
for i in 1:size(gbabs, 1)
    s = string(gbabs[i,:ems_sn])
    a = misstext(gbabs[i,:address_happen_si]*" ")*
        misstext(gbabs[i,:address_happen_gu]*" ")*
        misstext(gbabs[i,:address_happen_dong]*" ")*
        misstext(gbabs[i,:address_happen_bunji])
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
    query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    if p["meta"]["total_count"] == 0
        a = misstext(gbabs[i,:address_happen_si]*" ")*
            misstext(gbabs[i,:address_happen_gu]*" ")*
            misstext(gbabs[i,:address_happen_dong])
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
            println(s,"\t",a,"\t\t\t",x,"\t",y)
            push!(gbxy, [s a x y])
    catch
            x = "miss"
            y = "miss"
            println(s," ",a," ",x," ",y)
            push!(gbxy, [s a x y])
    end
end

CSV.write("gbxy.csv", gbxy)

gb[!,:survtoadm] = map(x -> 
    try;    ifelse(x == 10 || x == 21 || x == 30, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch;  return missing  end,
    gb[!,:er_result]) # 살면 1 죽으면 0

gb[!,:survtodis] = map(x ->
    try;    ifelse(x == 10 || x == 20 || x == 30 || x == 31, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch; return missing end,
    gb[!,:ad_result])

gb[!,:survdisfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    gb[!,:survtodis]
)

gb[!,:survadmfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    gb[!,:survtoadm]
)

gbarrest = hcat(gbabs, gbxy, gb[!,[:survadmfinal,:survdisfinal]])
CSV.write("gbarrest.csv", gbarrest)

gbsurvtoadm = gbarrest[gbarrest[!,:survadmfinal] .== 1,:]
gbsurvtodis = gbarrest[gbarrest[!,:survdisfinal] .== 1,:]
CSV.write("gbsurvtoadm.csv", gbsurvtoadm)
CSV.write("gbsurvtodis.csv", gbsurvtodis)





## 대구 만들기

daegu = arrest[arrest[!, :sido] .== "대구", :]

daeguabs = daegu[!,[:ems_sn,:fdsn,:nhosp,:age,:sex,:address_happen_si,
    :address_happen_gu,:address_happen_dong,:address_happen_bunji,
    :address_happen_else,:address_happen_else1,:address_f,
    :address_f_else,:sx1,:disease,:injury_detail,:test]]

function misstext(text)
    if ismissing(text); return ""; else return text ;end
end
    
daeguxy = DataFrame(serial = String[], juso = String[],
    x = String[], y = String[])
    
for i in 1:size(daeguabs, 1)
    s = string(daeguabs[i,:ems_sn])
    a = misstext(daeguabs[i,:address_happen_si]*" ")*
        misstext(daeguabs[i,:address_happen_gu]*" ")*
        misstext(daeguabs[i,:address_happen_dong]*" ")*
        misstext(daeguabs[i,:address_happen_bunji])
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
    query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    if p["meta"]["total_count"] == 0
        a = misstext(daeguabs[i,:address_happen_si]*" ")*
            misstext(daeguabs[i,:address_happen_gu]*" ")*
            misstext(daeguabs[i,:address_happen_dong])
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
            println(s,"\t",a,"\t\t\t",x,"\t",y)
            push!(daeguxy, [s a x y])
    catch
            x = "miss"
            y = "miss"
            println(s," ",a," ",x," ",y)
            push!(daeguxy, [s a x y])
    end
end

CSV.write("daeguxy.csv", daeguxy)

daegu[!,:survtoadm] = map(x -> 
    try;    ifelse(x == 10 || x == 21 || x == 30, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch;  return missing  end,
    daegu[!,:er_result]) # 살면 1 죽으면 0

daegu[!,:survtodis] = map(x ->
    try;    ifelse(x == 10 || x == 20 || x == 30 || x == 31, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch; return missing end,
    daegu[!,:ad_result])

daegu[!,:survdisfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    daegu[!,:survtodis]
)

daegu[!,:survadmfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    daegu[!,:survtoadm]
)

daeguarrest = hcat(daeguabs, daeguxy, daegu[!,[:survadmfinal,:survdisfinal]])
CSV.write("daeguarrest.csv", daeguarrest)

daegusurvtoadm = daeguarrest[daeguarrest[!,:survadmfinal] .== 1,:]
daegusurvtodis = daeguarrest[daeguarrest[!,:survdisfinal] .== 1,:]
CSV.write("daegusurvtoadm.csv", daegusurvtoadm)
CSV.write("daegusurvtodis.csv", daegusurvtodis)





## 경남 만들기

gn = arrest[arrest[!, :sido] .== "경남", :]

gnabs = gn[!,[:ems_sn,:fdsn,:nhosp,:age,:sex,:address_happen_si,
    :address_happen_gu,:address_happen_dong,:address_happen_bunji,
    :address_happen_else,:address_happen_else1,:address_f,
    :address_f_else,:sx1,:disease,:injury_detail,:test]]

function misstext(text)
    if ismissing(text); return ""; else return text ;end
end
    
gnxy = DataFrame(serial = String[], juso = String[],
    x = String[], y = String[])
    
for i in 1:size(gnabs, 1)
    s = string(gnabs[i,:ems_sn])
    a = misstext(gnabs[i,:address_happen_si]*" ")*
        misstext(gnabs[i,:address_happen_gu]*" ")*
        misstext(gnabs[i,:address_happen_dong]*" ")*
        misstext(gnabs[i,:address_happen_bunji])
    r = HTTP.request("GET", 
        "https://dapi.kakao.com/v2/local/search/address.json"; 
        headers = 
        Dict("Authorization" => "KakaoAK 4566d147680f4ca06a30c943776a3aa5"), 
    query = Dict("query" => a))
    j = String(r.body)
    p = JSON.parse(j)
    if p["meta"]["total_count"] == 0
        a = misstext(gnabs[i,:address_happen_si]*" ")*
            misstext(gnabs[i,:address_happen_gu]*" ")*
            misstext(gnabs[i,:address_happen_dong])
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
            println(s,"\t",a,"\t\t\t",x,"\t",y)
            push!(gnxy, [s a x y])
    catch
            x = "miss"
            y = "miss"
            println(s," ",a," ",x," ",y)
            push!(gnxy, [s a x y])
    end
end

CSV.write("gnxy.csv", gnxy)

gn[!,:survtoadm] = map(x -> 
    try;    ifelse(x == 10 || x == 21 || x == 30, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch;  return missing  end,
    gn[!,:er_result]) # 살면 1 죽으면 0

gn[!,:survtodis] = map(x ->
    try;    ifelse(x == 10 || x == 20 || x == 30 || x == 31, 1,
            ifelse(x == 40 || x == 41, 0, missing))
    catch; return missing end,
    gn[!,:ad_result])

gn[!,:survdisfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    gn[!,:survtodis]
)

gn[!,:survadmfinal] = map(x ->
    if ismissing(x) return 0 elseif x == 1 return 1 else return 0 end,
    gn[!,:survtoadm]
)

gnarrest = hcat(gnabs, gnxy, gn[!,[:survadmfinal,:survdisfinal]])
CSV.write("gnarrest.csv", gnarrest)

gnsurvtoadm = gnarrest[gnarrest[!,:survadmfinal] .== 1,:]
gnsurvtodis = gnarrest[gnarrest[!,:survdisfinal] .== 1,:]
CSV.write("gnsurvtoadm.csv", gnsurvtoadm)
CSV.write("gnsurvtodis.csv", gnsurvtodis)

