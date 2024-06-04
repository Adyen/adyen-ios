# Define a method to check if a diff contains public reference changes
def diff_contains_public_reference_changes(diffs)

  # Iterate through the diff and check each change
  diffs.each do |diff|
    if diff.path.start_with?('Adyen')
      change = diff.patch
      
      # Iterate through the lines in the patch
      change.each_line do |line|
        case line
        when /^ /
          # Lines starting with a space are part of the context and are not considered modified
          next
        when /^\+/
          # Lines starting with '+' are additions
          if line.include?('public')
	    puts "Public reference added"
	    puts line
            return true
          end
          if line.include?('@_spi')
	    puts "Public reference removed"
	    puts line
            return true
          end
        when /^-/
          # Lines starting with '-' are removals
          if line.include?('public')
	    puts "Public reference removed"
	    puts line
            return true
          end
          if line.include?('@_spi')
	    puts "Public reference added"
	    puts line
            return true
          end
        end
      end
    end
  end

  return false # No public reference found in the specified folder
end

# Check if the MR diff contains public reference changes in the specified folder
if diff_contains_public_reference_changes(git.diff)
  # Post as comment
  puts "There were public interface changes - post this as a comment"
end