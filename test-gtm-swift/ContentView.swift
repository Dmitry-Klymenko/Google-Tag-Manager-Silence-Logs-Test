//
//  ContentView.swift
//  test-gtm-swift
//
//  Created by Dmitry Klymenko on 26/3/20.
//  Copyright © 2020 Capibara. All rights reserved.
//

import SwiftUI




struct ContentView: View {
    
    @State var timestamp: String;
    
    var body: some View {
        VStack {
            Text("Hello World")
            Text( timestamp )
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        return ContentView(timestamp:"test")
    }
}
