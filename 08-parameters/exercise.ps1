<#
.SYNOPSIS
    Work-in-progress exercises for Chapter 08: Parameters.

.DESCRIPTION
    Contains only the parameter concepts practised interactively so far.
    The exercise set will be expanded and finalized after the chapter is
    completed.

.NOTES
    Current checkpoint: Exercise 4 - Convert hours to minutes.
#>

# Exercise 1: Distinguish parameters from arguments
# Create a function named Get-Greeting.
# It should:
# - accept one string parameter named Name;
# - build the string "Hello, <Name>" in an internal variable named Message;
# - return Message through the success output stream.
#
# Invoke it once with named binding and once with positional binding.

# TODO: Write your function and invocations here.


# Exercise 2: Compare named and positional binding
# Create a function named Get-PersonalGreeting.
# It should accept these string parameters in this order:
# - Greeting;
# - Name.
#
# Return one string using this format:
# <Greeting>, <Name>
#
# Test it with:
# - named arguments written in the opposite order;
# - positional arguments written in the declared order;
# - positional arguments written in the opposite order.
#
# Explain why named argument order does not change the result and why
# positional argument order does.

# TODO: Write your function, invocations, and explanation here.


# Exercise 3: Observe parameter type conversion
# Create a function named Get-DoubledNumber.
# It should:
# - accept one integer parameter named Number;
# - return Number multiplied by 2.
#
# Test it with:
# - the integer 5;
# - the string "5";
# - the string "five".
#
# Explain which arguments are accepted, which conversion PowerShell performs,
# and why the function body does not run when conversion fails.

# TODO: Write your function, invocations, and explanation here.


# Exercise 4: Convert hours to minutes
# CURRENT LEARNING CHECKPOINT
#
# Create this function independently from the requirement:
#
# Function name: ConvertTo-Minutes
# Input: Hours
# Parameter type: integer
# Processing: multiply Hours by 60
# Output: calculated number of minutes
#
# Test it with:
# ConvertTo-Minutes -Hours 3
# ConvertTo-Minutes -Hours "3"
# ConvertTo-Minutes -Hours "three"
#
# Predict the behavior before running each invocation.

# TODO: Resume Chapter 08 here.
