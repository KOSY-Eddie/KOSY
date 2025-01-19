function either{
    parameter lor. // either should not be called directly, only from left or right

    function map { 
        parameter f.  // f is a function whose input is the contained type      
        if lor:haskey("left") {
            return either(lor).
        } else if lor:haskey("right"){
            return right(f(lor["right"])).
        }
    }

    function join {
        parameter ee. // is of type Either(Either(X))
        if ee:haskey("right"){
            return ee["show"]()["right"]["copy"]().
        }
        return ee["left"]().
    }

    function _bind { 
        parameter f. // f is a function that takes a value and returns an either
        return join(map(f)).
    }

    local out to lex( 
        "show", {return lor.},
        "map", map@,
        "bind", _bind@).

    local copyconstructor to donothing.
    for k in lor:keys{
        if k = "left" set copyconstructor to left@.
        else set copyconstructor to right@.
        set out[k] to copyconstructor:bind(lor[k]).
    }
    set out["copy"] to copyconstructor:bind(lor:values[0]).
    return out.
}

function left{
    parameter val. // left value (Error message + info)
    return either(lex("left",val)).
}

function right{
    parameter val. // right value (Happy Path!)
    return either(lex("right",val)).
}

// Safe division function that returns an Either
function safeDivide {
    parameter num, denom.
    if denom = 0 {
        return left("Division by zero error").
    }
    return right(num / denom).
}

// Function to double a number, returns Either
function double {
    parameter x.
    return right(x * 2).
}

// Test cases
function testDivision {
    // Test 1: Simple division
    local result1 is safeDivide(10, 2).
    print "10/2: " + result1:show().

    // Test 2: Division by zero
    local result2 is safeDivide(10, 0).
    print "10/0: " + result2:show().

    // Test 3: Chain operations
    // Try to divide 10 by 2, then double the result
    local result3 is safeDivide(10, 2):bind(double@).
    print "Double(10/2): " + result3:show().

    // Test 4: Chain with error
    // Try to divide 10 by 0, then double (should skip double)
    local result4 is safeDivide(10, 0):bind(double@).
    print "Double(10/0): " + result4:show().
}

// Run tests
testDivision().
