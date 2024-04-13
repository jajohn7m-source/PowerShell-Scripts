
function queryAccessByTitle() {
	$titles = Get-ADUser -Filter * -Properties Title | Select-Object -ExpandProperty Title -Unique

	# Uncomment below for testing - Comment the above out during testing.
	#$titles = Get-ADUser -Filter 'Title -like "*System Admin*"' -Properties Title | Select-Object -ExpandProperty Title -Unique
	
	# Create an empty array to store security groups for each title
	$securityGroupsByTitle = @{}

	# Loop through each title and retrieve the AD users with that title
	foreach ($title in $titles) {
		$users = Get-ADUser -Filter {Title -eq $title} | select -exp SamAccountName

		# Create an empty array to store security groups for t he current title
		$securityGroups = @()

		# Loop through each user and retrieve their security groups
		foreach ($user in $users) {
			$securityGroups += Get-ADPrincipalGroupMembership -Identity $user | Select-Object -ExpandProperty Name
		}

		# Store the security groups in the table with the title as the key
		$securityGroupsByTitle[$title] = $securityGroups | Select-Object -Unique
	}
	# incrementation variable
	$i = 1
	# appending html header title
	$html += '<h1> Security Groups By Title </h1>'
	# for each title
	foreach ($title in $titles) {
		# Append the increment number and title as header
		$html += '<h2>' + $i + '.) ' + $title + '</h2>'
		# create a div and set the id to the title specifically
		$html += '<div id="' + $title + '" class="member-list">'
		# append unordered list
		$html += '<ul>'
		# for each member in securityGroupsByTitle array using the title as key
		foreach ($member in $securityGroupsByTitle[$title]) {
			# Append each member as a list item header3 for visualization
			$html += '<li><h3>' + $member + '</h3></li>'
		}
		# after the for each loop we append the closing unorder list
		$html += '</ul>'
		# and also append the closing div tag
		$html += '</div>'
		# increment to the next title
		$i++
	}
	# append the closing body and html tags
	$html += '</body></html>'

# Write the HTML output to a file
$html | Out-File -FilePath "ADMembersByTitle.html" -Encoding UTF8
}

# call the function to generate a list of Security groups organized by their titles (uniquely) so no duplicate groups per title. 
queryAccessByTitle
