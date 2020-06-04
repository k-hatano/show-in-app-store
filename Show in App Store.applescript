use scripting additions
use framework "Foundation"

on run
	tell application "Finder"
		set fileItem to choose file
	end tell
	openFile(fileItem)
end run

on open fileItem
	openFile(fileItem)
end open

on openFile(fileItem)
	tell application "Finder"
		try
			set fullFileName to name of file fileItem
			set bundleIdentifier to id of application file fileItem
		on error
			activate
			display alert "Show in App Store" message quote & name of file fileItem & quote & " is not an application." buttons {"OK"} default button 1
			return
		end try
	end tell
	set appName to regexReplace(fullFileName, "\\.app", "")
	
	set curlUrl to "http://itunes.apple.com/lookup?bundleId=" & bundleIdentifier
	set curlResult to (do shell script "curl " & curlUrl)
	set appHttpUrl to regexMatch(curlResult, "\\\"trackViewUrl\\\":\\\"([^\\\"]+)\\\"")
	if (count appHttpUrl) = 0 then
		activate
		display alert "Show in App Store" message quote & appName & quote & " is not available on App Store now." buttons {"OK"} default button 1
		return
	end if
	
	set appUrl to regexReplace(item 2 of appHttpUrl, "http", "macappstore")
	open location appUrl
	tell application "App Store" to activate
end openFile

on regexMatch(source as text, pattern as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	set sourceString to current application's NSString's stringWithString:source
	set matches to regularExpression's matchesInString:source options:0 range:{location:0, |length|:count source}
	if (count matches) = 0 then return {}
	
	set match to matches's objectAtIndex:0
	set matchResult to {}
	repeat with i from 0 to (match's numberOfRanges as integer) - 1
		set end of matchResult to (sourceString's substringWithRange:(match's rangeAtIndex:i)) as text
	end repeat
	return matchResult
end regexMatch

on regexReplace(source as text, pattern as text, replaceText as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	return (regularExpression's stringByReplacingMatchesInString:source options:0 range:{location:0, |length|:count source} withTemplate:replaceText) as text
end regexReplace


