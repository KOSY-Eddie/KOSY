runOncePath("/KOSY/lib/kobject.ks").

function QuickSort {
    local self is Object():extend.
    self:setClassName("QuickSort").
    
    local function swap {
        parameter arr, i, j.
        local temp is arr[i].
        set arr[i] to arr[j].
        set arr[j] to temp.
    }

    local function partition {
        parameter arr, low, high.
        local pivot is arr[high].
        local i is low - 1.
        
        from { local j is low. } until j >= high step { set j to j + 1. } do {
            if arr[j]:compare(pivot) < 0 {
                set i to i + 1.
                swap(arr, i, j).
            }
        }
        swap(arr, i + 1, high).
        return i + 1.
    }

    self:protected("quickSort", {
        parameter arr, low, high.
        if low < high {
            local pivotIndex is partition(arr, low, high).
            self:quickSort(arr, low, pivotIndex - 1).
            self:quickSort(arr, pivotIndex + 1, high).
        }
    }).
    
    self:public("sort", {
        parameter arr.
        if arr:length > 1 {
            self:quickSort(arr, 0, arr:length - 1).
        }
    }).

    return defineObject(self).
}
