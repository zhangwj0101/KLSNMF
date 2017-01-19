function result = getRand(min,max)
res = 0.5;
while(1)
    res = min+(max-min)*rand();
    if res > min & res < max
        break;
    end
end
result = res;