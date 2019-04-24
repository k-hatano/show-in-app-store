use scripting additions
use framework "Foundation"

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

on openFile(appItem)
	tell application "Finder"
		try
			set appName to name of file appItem
		on error
			activate
			display alert "Show in App Store" message "The item you selected is not an application." buttons {"OK"} default button 1
			return
		end try
	end tell
	set rawAppName to replace_chars(appName, ".app", "")
	tell application "Finder"
		try
			set bundleIdentifier to id of application file appItem
		on error
			activate
			set resultButton to display alert "Show in App Store" message quote & name of file appItem & quote & " is not an application." buttons {"OK"} default button 1
			return
		end try
	end tell
	set newLocation to "http://itunes.apple.com/lookup?bundleId=" & bundleIdentifier
	set requestResult to (do shell script "curl " & newLocation)
	set appStoreIds to regexMatches(requestResult, "\\\"trackViewUrl\\\":\\\"([^\\\"]+)\\\"")
	if (count of appStoreIds) = 0 then
		activate
		display alert "Show in App Store" message quote & rawAppName & quote & " is not available on App Store now." buttons {"OK"} default button 1
	else
		set tmpUrl to item 2 of item 1 of appStoreIds
		set newUrl to replace_chars(tmpUrl, "http", "macappstore")
		open location newUrl
		tell application "App Store"
			activate
		end tell
	end if
end openFile

on regexMatches(aText as text, pattern as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	set aString to current application's NSString's stringWithString:aText
	set matches to regularExpression's matchesInString:aString options:0 range:{location:0, |length|:aString's |length|()}
	
	set matchResultList to {}
	repeat with match in matches
		set matchResult to {}
		repeat with i from 0 to (match's numberOfRanges as integer) - 1
			set end of matchResult to (aString's substringWithRange:(match's rangeAtIndex:i)) as text
		end repeat
		set end of matchResultList to matchResult
	end repeat
	return matchResultList
end regexMatches

on run
	tell application "Finder"
		set fileItem to (choose file)
		set aliasPath to fileItem as text
		set posixFile to aliasPath as POSIX file
	end tell
	openFile(fileItem)
end run

on open appItem
	openFile(appItem)
end open
