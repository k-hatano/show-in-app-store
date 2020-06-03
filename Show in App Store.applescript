use scripting additions
use framework "Foundation"

on run
	tell application "Finder"
		set fileItem to choose file
		set posixFile to (fileItem as text) as POSIX file
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
			set resultButton to display alert "Show in App Store" message quote & name of file fileItem & quote & " is not an application." buttons {"OK"} default button 1
			return
		end try
	end tell
	set appName to regexReplace(fullFileName, "\\.app", "")
	
	set newLocation to "http://itunes.apple.com/lookup?bundleId=" & bundleIdentifier
	set curlResult to (do shell script "curl " & newLocation)
	set appStoreIds to regexMatches(curlResult, "\\\"trackViewUrl\\\":\\\"([^\\\"]+)\\\"")
	if (count of appStoreIds) = 0 then
		activate
		display alert "Show in App Store" message quote & appName & quote & " is not available on App Store now." buttons {"OK"} default button 1
		return
	end if
	
	set appUrl to regexReplace(item 2 of item 1 of appStoreIds, "http", "macappstore")
	open location appUrl
	tell application "App Store" to activate
end openFile

on regexMatches(sourceText as text, pattern as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	set sourceString to current application's NSString's stringWithString:sourceText
	set matches to regularExpression's matchesInString:sourceText options:0 range:{location:0, |length|:count sourceText}
	
	set matchResultList to {}
	repeat with match in matches
		set matchResult to {}
		repeat with i from 0 to (match's numberOfRanges as integer) - 1
			set end of matchResult to (sourceString's substringWithRange:(match's rangeAtIndex:i)) as text
		end repeat
		set end of matchResultList to matchResult
	end repeat
	return matchResultList
end regexMatches

on regexReplace(sourceText as text, pattern as text, replaceText as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	return (regularExpression's stringByReplacingMatchesInString:sourceText options:0 range:{location:0, |length|:count sourceText} withTemplate:replaceText) as text
end regexReplace


