


if(FALSE){
    ## Read original file
    recs <- RJSONIO::fromJSON("../sdp-business.json/ResultSet.json")
    
    ## Convert to JSON
    recs_text <- RJSONIO::toJSON(recs, digits = 16)
    
    ## Write new JSON file
    writeLines(text = recs_text, con = "../sdp-business.json/ResultSet_roundtrip.json")
    
    ## Compare new and old JSON files
    system("diff -w ../sdp-business.json/ResultSet.json ../sdp-business.json/ResultSet_roundtrip.json")
    
    ## Delete new JSON file 
    # system("rm ../sdp-business.json/ResultSet_roundtrip.json")
    
}




