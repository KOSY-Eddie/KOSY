clearscreen.
runOncePath("/KOSY/lib/quicksort.ks").
runOncePath("/KOSY/lib/test/UnitTest.ks").

// Test object that implements compare
function SortableItem {
    parameter value.
    local self is Object():extend.
    
    self:public("value", value).
    
    self:public("compare", {
        parameter other.
        return self:value - other:value:get().
    }).
    
    // For test output clarity
    self:public("toString", {
        return value:toString.
    }).
    
    return defineObject(self).
}

function QuickSortTests {
    local self is UnitTest():extend().
    
    // Helper to create sortable list
    local function createList {
        parameter values.
        local result is list().
        for value in values {
            result:add(SortableItem(value):new).
        }
        return result.
    }.
    
    // Helper to verify list is sorted
    local function isSorted {
        parameter arr.
        if arr:length <= 1 return true.
        
        from { local i is 1. } until i >= arr:length step { set i to i + 1. } do {
            if arr[i]:value:get() < arr[i-1]:value:get() return false.
        }.
        return true.
    }.
    
    // Basic sorting
    self:test("Basic Sorting", {
        local sorter is QuickSort():new.
        
        // Simple unsorted list
        local list1 is createList(list(5,2,8,1,9,3)).
        sorter:sort(list1).
        self:assert(isSorted(list1), "Basic list sorted correctly").
        
        // Already sorted list
        local list2 is createList(list(1,2,3,4,5)).
        sorter:sort(list2).
        self:assert(isSorted(list2), "Already sorted list remains sorted").
        
        // Reverse sorted list
        local list3 is createList(list(5,4,3,2,1)).
        sorter:sort(list3).
        self:assert(isSorted(list3), "Reverse sorted list sorts correctly").
    }).
    
    // Edge Cases
    self:test("Edge Cases", {
        local sorter is QuickSort():new.
        
        // Empty list
        local emptyList is list().
        sorter:sort(emptyList).
        self:assertEqual(emptyList:length, 0, "Empty list remains empty").
        
        // Single item
        local singleList is createList(list(1)).
        sorter:sort(singleList).
        self:assertEqual(singleList:length, 1, "Single item list unchanged").
        
        // Two items in wrong order
        local twoList is createList(list(2,1)).
        sorter:sort(twoList).
        self:assert(isSorted(twoList), "Two item list sorts correctly").
        
        // List with duplicate values
        local dupList is createList(list(3,1,3,2,3)).
        sorter:sort(dupList).
        self:assert(isSorted(dupList), "List with duplicates sorts correctly").
    }).
    
    // Stress Tests
    self:test("Stress Tests", {
        local sorter is QuickSort():new.
        
        // Large list
        local largeList is list().
        from { local i is 0. } until i >= 100 step { set i to i + 1. } do {
            largeList:add(SortableItem(random() * 1000):new).
        }.
        sorter:sort(largeList).
        self:assert(isSorted(largeList), "Large random list sorts correctly").
        
        // List with many duplicates
        local dupList is list().
        from { local i is 0. } until i >= 50 step { set i to i + 1. } do {
            dupList:add(SortableItem(round(random() * 5)):new).
        }.
        sorter:sort(dupList).
        self:assert(isSorted(dupList), "List with many duplicates sorts correctly").
    }).
    
    // Special Values
    self:test("Special Values", {
        local sorter is QuickSort():new.
        
        // List with negative numbers
        local negList is createList(list(-5,3,-2,1,-8,4)).
        sorter:sort(negList).
        self:assert(isSorted(negList), "List with negative numbers sorts correctly").
        
        // List with zero
        local zeroList is createList(list(3,0,2,0,1,0)).
        sorter:sort(zeroList).
        self:assert(isSorted(zeroList), "List with zeros sorts correctly").
        
        // Very large numbers
        local largeNumList is createList(list(99999,1,-99999,50000)).
        sorter:sort(largeNumList).
        self:assert(isSorted(largeNumList), "List with large numbers sorts correctly").
    }).
    
    // Stability Test (though QuickSort isn't guaranteed to be stable)
    self:test("Complex Objects", {
        // Create objects with same compare value but different data
        function ComplexItem {
            parameter sortValue, data.
            local self is Object():extend.
            
            self:public("compare", {
                parameter other.
                return self:sortValue - other:sortValue:get().
            }).
            
            self:public("sortValue", sortValue).
            self:public("data", data).
            
            return defineObject(self).
        }.
        
        local sorter is QuickSort():new.
        local complexList is list().
        complexList:add(ComplexItem(1, "A"):new).
        complexList:add(ComplexItem(1, "B"):new).
        complexList:add(ComplexItem(2, "C"):new).
        complexList:add(ComplexItem(2, "D"):new).
        
        sorter:sort(complexList).
        
        // Verify sorting by sortValue
        from { local i is 1. } until i >= complexList:length step { set i to i + 1. } do {
            self:assert(
                complexList[i]:sortValue:get() >= complexList[i-1]:sortValue:get(),
                "Complex objects sorted by sortValue"
            ).
        }.
    }).
    
    return defineObject(self).
}

// Run the tests
local runner is UnitTestRunner():new.
runner:addSuite(QuickSortTests():new).
runner:runAll().
