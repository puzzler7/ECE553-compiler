val args = CommandLine.arguments()
fun sum l = foldr op+ 0 (map (valOf o Int.fromString) l)
fun parseAll fileNames = 
    foldl (
        fn (fileName, _) => 
            Parse.parse(fileName)     
    ) () fileNames
val _ = parseAll(args)
val _ = OS.Process.exit(OS.Process.success)