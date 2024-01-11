//
//  ChartViewB.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/9/23.
//

import SwiftUI
import Charts

struct ChartViewB: View {
    var body: some View {
        Chart(ChartData.sample, id: \.title) { element in
            LineMark (
            x: .value("Sales", element.value),
            y: .value("Sales", element.value)
            )
            .foregroundStyle(by:.value("sales", element.title))
        }
        .chartXAxis(.hidden)
    }
}

struct ChartViewB_Previews: PreviewProvider {
    static var previews: some View {
        ChartViewB()
    }
}
