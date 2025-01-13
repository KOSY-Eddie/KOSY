runOncePath("/KOSY/lib/kobject.ks").

function MinHeap {
    local self is Object():extend.
    self:setClassName("MinHeap").
    
    local heap_list is list().
    local count is 0.
    
    // Helper functions for 4-ary heap
    local function get_children_indices {
        parameter index.
        local firstChild is index * 4 + 1.
        return list(
            firstChild,
            firstChild + 1,
            firstChild + 2,
            firstChild + 3
        ).
    }
    
    local function get_min_child {
        parameter index.
        local children is get_children_indices(index).
        local firstChild is children[0].
        
        if firstChild >= count { return index. }
        
        local minIdx is firstChild.
        local minElement is heap_list[firstChild].
        
        from { local i is 1. }
        until i >= 4 or (firstChild + i) >= count
        step { set i to i + 1. } do {
            local childIdx is firstChild + i.
            local child is heap_list[childIdx].
            if child:compare(minElement) < 0 {
                set minIdx to childIdx.
                set minElement to child.
            }
        }
        
        return minIdx.
    }
    
    local function bubble_down {
        parameter index.
        local item is heap_list[index].
        
        until index * 4 + 1 >= count {
            local minChildIdx is get_min_child(index).
            if minChildIdx = index or item:compare(heap_list[minChildIdx]) <= 0 {
                break.
            }
            
            set heap_list[index] to heap_list[minChildIdx].
            set index to minChildIdx.
        }
        set heap_list[index] to item.
    }
    
    // Public interface
    self:public("insert", {
        parameter element.
        heap_list:add(element).
        set count to count + 1.
        
        // Optimized bubble up
        local currentIdx is count - 1.
        local item is element.
        
        until currentIdx <= 0 {
            local parentIdx is floor((currentIdx - 1) / 4).
            if item:compare(heap_list[parentIdx]) >= 0 {
                break.
            }
            set heap_list[currentIdx] to heap_list[parentIdx].
            set currentIdx to parentIdx.
        }
        set heap_list[currentIdx] to item.
    }).
    
    self:public("extract_min", {
        if count = 0 {
            return null.
        }
        
        local minElement is heap_list[0].
        
        set count to count - 1.
        if count > 0 {
            local lastElement is heap_list[count].
            heap_list:remove(count).
            set heap_list[0] to lastElement.
            bubble_down(0).
        } else {
            heap_list:clear().
        }
        
        return minElement.
    }).

    self:public("peek", {
        if count = 0 {
            return null.
        }
        return heap_list[0].
    }).
    
    self:public("size", {
        return count.
    }).

    self:public("isEmpty", {
        return count = 0.
    }).
    
    return defineObject(self).
}
