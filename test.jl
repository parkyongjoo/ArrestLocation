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
#=
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

=#

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


gndist = CSV.read("../data/gnarrestdistricjoined.csv", header = 1)

gndistnomiss = gndist[gndist[!,:ADM_DR_NM] .!== missing,:]

#=
gnmilsam = gndistnomiss[gndistnomiss[!,:ADM_DR_NM] .== "삼문동",:]
gnchangsang = gndistnomiss[gndistnomiss[!,:ADM_DR_NM] .== "상남동",:]
set = vcat(gnmilsam, gnchangsang)

using GLM

model = glm(@formula(survadmfinal ~ ADM_DR_NM + age),
    set, Binomial(), LogitLink()
)
conf = convert(DataFrame, exp.(confint(model)))
coeff = DataFrame(OR = exp.(coef(model)))
coeffnames = DataFrame(names = coefnames(model))
result = rename(hcat(coeffnames, coeff, conf), Dict(:x1 => Symbol("2.5%"),
    :x2 => Symbol("97.5%"))
)

gndistnomiss[!,:ADM_DR_NM] = map(x ->
    ifelse(x == "상남동", "1.상남동", x), gndistnomiss[!,:ADM_DR_NM]
)

model = glm(@formula(survadmfinal ~ ADM_DR_NM + age),
    gndistnomiss, Binomial(), LogitLink()
)
conf = convert(DataFrame, exp.(confint(model)))
coeff = DataFrame(OR = exp.(coef(model)))
coeffnames = DataFrame(names = coefnames(model))
result = rename(hcat(coeffnames, coeff, conf), Dict(:x1 => Symbol("2.5%"),
    :x2 => Symbol("97.5%"))
)
=#


gndistnomiss[!,:district] = map(x->
#   창원시 의창구 3811111 동읍
#   창원시 의창구 3811131 북면
#   창원시 의창구 3811132 대산면
    ifelse(x == 3811111 || x == 3811131 || x == 3811132,
    "창원읍면", 
#   창원시 의창구 3811151 의창동
#   창원시 의창구 3811152 팔룡동
#   창원시 의창구 3811153 명곡동
#   창원시 의창구 3811154 봉림동
#   창원시 의창구 3811155 용지동
#   창원시 성산구 3811251 반송동
#   창원시 성산구 3811252 중앙동
#   창원시 성산구 3811253 상남동
#   창원시 성산구 3811254 사파동
#   창원시 성산구 3811255 가음정동
#   창원시 성산구 3811256 성주동
#   창원시 성산구 3811257 웅남동
    ifelse(x == 3811151 || x == 3811152 || x == 3811153 ||
        x == 3811154 || x == 3811155 || x == 3811251 ||
        x == 3811252 || x == 3811253 || x == 3811254 ||
        x == 3811255 || x == 3811256 || x == 3811257,
    "1.창원시내", 
#   창원시 마산합포구 3811331 구산면
#   창원시 마산합포구 3811332 진동면
#   창원시 마산합포구 3811333 진북면
#   창원시 마산합포구 3811334 진전면
#   창원시 마산회원구 3811411 내서읍
    ifelse(x == 3811331 || x == 3811332 || x == 3811333 ||
    x == 3811334 || x == 3811411,
    "마산읍면",    
#    창원시 마산합포구 3811351 현동
#    창원시 마산합포구 3811352 가포동
#    창원시 마산합포구 3811353 월영동
#    창원시 마산합포구 3811354 문화동
#    창원시 마산합포구 3811355 반월동
#    창원시 마산합포구 3811356 중앙동
#    창원시 마산합포구 3811357 완월동
#    창원시 마산합포구 3811358 자산동
#    창원시 마산합포구 3811359 동서동
#    창원시 마산합포구 3811360 성호동
#    창원시 마산합포구 3811361 교방동
#    창원시 마산합포구 3811362 노산동
#    창원시 마산합포구 3811363 오동동
#    창원시 마산합포구 3811364 합포동
#    창원시 마산합포구 3811365 산호동
#    3811366 반월중앙동 3811367 오동동
#    창원시 마산회원구 3811451 회원1동
#    창원시 마산회원구 3811452 회원2동
#    창원시 마산회원구 3811453 석전1동
#    창원시 마산회원구 3811454 석전2동
#    창원시 마산회원구 3811455 회성동
#    창원시 마산회원구 3811456 양덕1동
#    창원시 마산회원구 3811457 양덕2동
#    창원시 마산회원구 3811458 합성1동
#    창원시 마산회원구 3811459 합성2동
#    창원시 마산회원구 3811460 구암1동
#    창원시 마산회원구 3811461 구암2동
#    창원시 마산회원구 3811462 봉암동
#    3811463 석전동?
    ifelse(3811351 <= x <= 3811367 ||
            3811451 <= x <= 3811463,
    "마산시내",
#    창원시 진해구 3811551 중앙동
#    창원시 진해구 3811552 태평동
#    창원시 진해구 3811553 충무동
#    창원시 진해구 3811554 여좌동
#    창원시 진해구 3811555 태백동
#    창원시 진해구 3811556 경화동
#    창원시 진해구 3811557 병암동
#    창원시 진해구 3811558 석동
#    창원시 진해구 3811559 이동
#    창원시 진해구 3811560 자은동
#    창원시 진해구 3811561 덕산동
#    창원시 진해구 3811562 풍호동
#    창원시 진해구 3811563 웅천동
#    창원시 진해구 3811564 웅동1동
#    창원시 진해구 3811565 웅동2동
    ifelse(3811551 <= x <= 3811565,
    "진해시내",
#    의령군 3831011 의령읍
    ifelse(x == 3831011,
    "의령읍",
#    의령군 3831031 가례면
#    의령군 3831032 칠곡면
#    의령군 3831033 대의면
#    의령군 3831034 화정면
#    의령군 3831035 용덕면
#    의령군 3831036 정곡면
#    의령군 3831037 지정면
#    의령군 3831038 낙서면
#    의령군 3831039 부림면
#    의령군 3831040 봉수면
#    의령군 3831041 궁류면
#    의령군 3831042 유곡면
    ifelse(3831031 <= x <= 3831042,
    "의령",
#    함안군 3832011 가야읍
#    함안군 3832012 칠원읍
    ifelse(x == 3832011,
    "함안가야읍",
    ifelse(x == 3832012,
    "함안칠원읍",
#    함안군 3832031 함안면
#    함안군 3832032 군북면
#    함안군 3832033 법수면
#    함안군 3832034 대산면
#    함안군 3832035 칠서면
#    함안군 3832036 칠북면
#    함안군 3832038 산인면
#    함안군 3832039 여항면
    ifelse(3832031 <= x <= 3832039,
    "함안",
#    창녕군 3833011 창녕읍
    ifelse(x == 3833011,
    "창녕읍",
#    창녕군 3833012 남지읍
    ifelse(x == 3833012,
    "창녕남지읍",
#    창녕군 3833031 고암면
#    창녕군 3833032 성산면
#    창녕군 3833033 대합면
#    창녕군 3833034 이방면
#    창녕군 3833035 유어면
#    창녕군 3833036 대지면
#    창녕군 3833037 계성면
#    창녕군 3833038 영산면
#    창녕군 3833039 장마면
#    창녕군 3833040 도천면
#    창녕군 3833041 길곡면
#    창녕군 3833042 부곡면
    ifelse(3833031 <= x <= 3833042,
    "창녕",
#    고성군 3834011 고성읍
    ifelse(x == 3834011,
    "고성읍",
#    고성군 3834031 삼산면
#    고성군 3834032 하일면
#    고성군 3834033 하이면
#    고성군 3834034 상리면
#    고성군 3834035 대가면
#    고성군 3834036 영현면
#    고성군 3834037 영오면
#    고성군 3834038 개천면
#    고성군 3834039 구만면
#    고성군 3834040 회화면
#    고성군 3834041 마암면
#    고성군 3834042 동해면
#    고성군 3834043 거류면
    ifelse(3834031 <= x <= 3834043,
    "고성",
#    남해군 3835011 남해읍
    ifelse(x == 3835011,
    "남해읍",
#    남해군 3835031 이동면
#    남해군 3835032 상주면
#    남해군 3835033 삼동면
#    남해군 3835034 미조면
#    남해군 3835035 남면
#    남해군 3835036 서면
#    남해군 3835037 고현면
#    남해군 3835038 설천면
#    남해군 3835039 창선면
    ifelse(3835031 <= x <= 3835039,
    "남해",
#   하동군 3836011 하동읍
    ifelse(x == 3836011,
    "하동읍",
#    하동군 3836031 화개면
#    하동군 3836032 악양면
#    하동군 3836033 적량면
#    하동군 3836034 횡천면
#    하동군 3836035 고전면
#    하동군 3836036 금남면
#    하동군 3836037 금성면
#    하동군 3836038 진교면
#    하동군 3836039 양보면
#    하동군 3836040 북천면
#    하동군 3836041 청암면
#    하동군 3836042 옥종면
    ifelse(3836031 <= x <= 3836042,
    "하동",
#   산청군 3837011 산청읍
    ifelse(x == 3837011,
    "산청읍",
#    산청군 3837031 차황면
#    산청군 3837032 오부면
#    산청군 3837033 생초면
#    산청군 3837034 금서면
#    산청군 3837035 삼장면
#    산청군 3837036 시천면
#    산청군 3837037 단성면
#    산청군 3837038 신안면
#    산청군 3837039 생비량면
#    산청군 3837040 신등면
    ifelse(3837031 <= x <= 3837040,
    "산청",
#    함양군 3838011 함양읍
    ifelse(x == 3838011,
    "함양읍",
#    함양군 3838031 마천면
#    함양군 3838032 휴천면
#    함양군 3838033 유림면
#    함양군 3838034 수동면
#    함양군 3838035 지곡면
#    함양군 3838036 안의면
#    함양군 3838037 서하면
#    함양군 3838038 서상면
#    함양군 3838039 백전면
#    함양군 3838040 병곡면
    ifelse(3838031 <= x <= 3838040,
    "함양",
#    거창군 3839011 거창읍
    ifelse(x == 3839011,
    "거창읍",
#    거창군 3839031 주상면
#    거창군 3839032 웅양면
#    거창군 3839033 고제면
#    거창군 3839034 북상면
#    거창군 3839035 위천면
#    거창군 3839036 마리면
#    거창군 3839037 남상면
#    거창군 3839038 남하면
#    거창군 3839039 신원면
#    거창군 3839040 가조면
#    거창군 3839041 가북면
    ifelse(3839031 <= x <= 3839041,
    "거창",
#    합천군 3840011 합천읍
    ifelse(x == 3840011,
    "합천읍", 
#    합천군 3840031 봉산면
#    합천군 3840032 묘산면
#    합천군 3840033 가야면
#    합천군 3840034 야로면
#    합천군 3840035 율곡면
#    합천군 3840036 초계면
#    합천군 3840037 쌍책면
#    합천군 3840038 덕곡면
#    합천군 3840039 청덕면
#    합천군 3840040 적중면
#    합천군 3840041 대양면
#    합천군 3840042 쌍백면
#    합천군 3840043 삼가면
#    합천군 3840044 가회면
#    합천군 3840045 대병면
#    합천군 3840046 용주면
    ifelse(3840031 <= x <= 3840046,
    "합천", 
#    진주시 3803011 문산읍
#    진주시 3803031 내동면
#    진주시 3803032 정촌면
#    진주시 3803033 금곡면
#    진주시 3803034 진성면
#    진주시 3803035 일반성면
#    진주시 3803036 이반성면
#    진주시 3803037 사봉면
#    진주시 3803038 지수면
#    진주시 3803039 대곡면
#    진주시 3803040 금산면
#    진주시 3803041 집현면
#    진주시 3803042 미천면
#    진주시 3803043 명석면
#    진주시 3803044 대평면
#    진주시 3803045 수곡면
    ifelse(x == 3803011 || 3803031 <= x <= 3803045,
    "진주",
#    진주시 3803061 상대1동
#    진주시 3803062 상대2동
#    진주시 3803063 하대1동
#    진주시 3803064 하대2동
#    진주시 3803065 상평동
#    진주시 3803066 초장동
#    진주시 3803067 평거동
#    진주시 3803068 신안동
#    진주시 3803069 이현동
#    진주시 3803070 판문동
#    진주시 3803071 가호동
#    진주시 3803072 천전동
#    진주시 3803073 성북동
#    진주시 3803074 중앙동
#    진주시 3803075 상봉동
#    진주시 3803076 충무공동
#    3803078 하대동? 3803077 상대동?
    ifelse(3803061 <= x <= 3803076,
    "진주시내",
#    통영시 3805011 산양읍
#    통영시 3805031 용남면
#    통영시 3805032 도산면
#    통영시 3805033 광도면
#    통영시 3805034 욕지면
#    통영시 3805035 한산면
#    통영시 3805036 사량면
    ifelse( x == 3805011 || 3805031 <= x <= 3805036,
    "통영",
#    통영시 3805052 명정동
#    통영시 3805053 중앙동
#    통영시 3805054 정량동
#    통영시 3805055 북신동
#    통영시 3805056 무전동
#    통영시 3805062 도천동
#    통영시 3805063 미수동
#    통영시 3805064 봉평동
    ifelse( 3805052 <= x <= 3805056 || 3805062 <= x <= 3805064,
    "통영시내",
#    사천시 3806011 사천읍
#    사천시 3806031 정동면
#    사천시 3806032 사남면
#    사천시 3806033 용현면
#    사천시 3806034 축동면
#    사천시 3806035 곤양면
#    사천시 3806036 곤명면
#    사천시 3806037 서포면
    ifelse( x == 3806011 || 3806031 <= x <= 3806037,
    "사천",
#    사천시 3806051 동서동
#    사천시 3806052 선구동
#    사천시 3806053 동서금동
#    사천시 3806055 벌룡동
#    사천시 3806057 향촌동
#    사천시 3806059 남양동
    ifelse( 3806051 <= x <= 3806053 || 
        x == 3806055 || x <= 3806057 || x <= 3806059,
    "사천시내",
#    김해시 3807011 진영읍
#    김해시 3807032 주촌면
#    김해시 3807033 진례면
#    김해시 3807034 한림면
#    김해시 3807035 생림면
#    김해시 3807036 상동면
#    김해시 3807037 대동면
    ifelse( x == 3807011 || 3807032 <= x <= 3807037,
    "김해",
#    김해시 3807051 동상동
#    김해시 3807052 회현동
#    김해시 3807053 부원동
#    김해시 3807054 내외동
#    김해시 3807055 북부동
#    김해시 3807056 칠산서부동
#    김해시 3807058 활천동
#    김해시 3807059 삼안동
#    김해시 3807060 불암동
#    김해시 3807061 장유1동
#    김해시 3807062 장유2동
#    김해시 3807063 장유3동
    ifelse( 3807051 <= x <= 3807056 || 3807058 <= x <= 3807063,
    "김해시내",
#    밀양시 3808011 삼랑진읍
#    밀양시 3808012 하남읍
#    밀양시 3808031 부북면
#    밀양시 3808032 상동면
#    밀양시 3808033 산외면
#    밀양시 3808034 산내면
#    밀양시 3808035 단장면
#    밀양시 3808036 상남면
#    밀양시 3808037 초동면
#    밀양시 3808038 무안면
#    밀양시 3808039 청도면
    ifelse( 3808011 <= x <= 3808012 || 3808031 <= x <= 3808039,
    "밀양",
#    밀양시 3808051 내일동
#    밀양시 3808052 내이동
#    밀양시 3808053 교동
#    밀양시 3808054 삼문동
#    밀양시 3808055 가곡동
    ifelse( 3808051 <= x <= 3808055,
    "밀양시내",
#    거제시 3809031 일운면
#    거제시 3809032 동부면
#    거제시 3809033 남부면
#    거제시 3809034 거제면
#    거제시 3809035 둔덕면
#    거제시 3809036 사등면
#    거제시 3809037 연초면
#    거제시 3809038 하청면
#    거제시 3809039 장목면
    ifelse( 3809031 <= x <= 3809039,
    "거제",
#    거제시 3809053 능포동
#    거제시 3809054 아주동
#    거제시 3809055 옥포1동
#    거제시 3809056 옥포2동
#    거제시 3809057 장평동
#    거제시 3809058 고현동
#    거제시 3809059 상문동
#    거제시 3809060 수양동
#    거제시 3809061 장승포동
    ifelse( 3809053 <= x <= 3809061,
    "거제시내",
#    양산시 3810012 물금읍
#    양산시 3810031 동면
#    양산시 3810032 원동면
#    양산시 3810033 상북면
#    양산시 3810034 하북면
    ifelse( x == 3810012 || 3810031 <= x <= 3810034,
    "양산",
#    양산시 3810052 삼성동
#    양산시 3810053 강서동
#    양산시 3810054 서창동
#    양산시 3810055 소주동
#    양산시 3810056 평산동
#    양산시 3810057 덕계동
#    양산시 3810058 중앙동
#    양산시 3810059 양주동
    ifelse( 3810052 <= x <= 3810059,
    "양산시내",
    "기타")
    )))))))))))))))))))))))))))))))))))))))),
    gndistnomiss[!,:ADM_DR_CD]
)

show(countmap(gndistnomiss[!,:district]))

model = glm(@formula(survadmfinal ~ district + age),
           gndistnomiss, Binomial(), LogitLink())
conf = convert(DataFrame, exp.(confint(model)))
coeff = DataFrame(OR = exp.(coef(model)))
coeffnames = DataFrame(names = coefnames(model))
result = rename(hcat(coeffnames, coeff, conf), Dict(:x1 => Symbol("2.5%"),
           :x2 => Symbol("97.5%"))
)
showall(result)

