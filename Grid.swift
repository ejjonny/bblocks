import Foundation

struct Point: Equatable {
    let x: Int
    let y: Int
}

struct Grid<T> {
    var rows: [[T]]
    subscript(i: Int) -> T {
        get {
            let coords = coord(i)
            return self[coords.x, coords.y]
        }
        set {
            let coords = coord(i)
            self[coords.x, coords.y] = newValue
        }
    }
    subscript(_ point: Point) -> T {
        get {
            return self[point.x, point.y]
        }
        set {
            self[point.x, point.y] = newValue
        }
    }
    subscript(x: Int, y: Int) -> T {
        get {
            return rows[y][x]
        }
        set {
            guard rows.indices.contains(y),
                  rows[y].indices.contains(x) else {
                return
            }
            rows[y][x] = newValue
        }
    }
    func coord(_ i: Int) -> Point {
        var y = 0
        var x = i
        while x >= rows[y].count {
            x -= rows[y].count
            y += 1
        }
        return .init(x: x, y: y)
    }
    var items: [T] {
        var items = [T]()
        for row in rows {
            items.append(contentsOf: row)
        }
        return items
    }
    func neighborPoints(_ i: Int) -> [Point] {
        let c = coord(i)
        let h = (c.x - 1)...(c.x + 1)
        let v = (c.y - 1)...(c.y + 1)
        var list = [Point]()
        for x in h {
            for y in v {
                guard self.rows.indices.contains(y),
                      self.rows[y].indices.contains(x),
                      c != Point(x: x, y: y) else {
                    continue
                }
                list.append(.init(x: x, y: y))
            }
        }
        return list
    }
    func neighbors(_ i: Int) -> [T] {
        neighborPoints(i).map { self[$0.x, $0.y] }
    }
}
