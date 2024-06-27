//
//  MuscleShapes.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 6/25/24.
//

import Foundation
import SwiftUI

// To use this shape, just add it to your SwiftUI View:
// WholeBody().fill().frame(width: 66.70126342773438, height: 143.2188720703125)

struct Silhouette: Shape {
        func path(in rect: CGRect) -> Path {
                var path = Path()
                let width = rect.size.width
                let height = rect.size.height
                path.move(to: CGPoint(x: 0.3313374704*width, y: 0.1815403209*height))
                path.addCurve(to: CGPoint(x: 0.2188958079*width, y: 0.2758016681*height), control1: CGPoint(x: 0.2173965945*width, y: 0.1927120357*height), control2: CGPoint(x: 0.2089009899*width, y: 0.2490361168*height))
                path.addCurve(to: CGPoint(x: 0.196407564*width, y: 0.3456248418*height), control1: CGPoint(x: 0.2113997266*width, y: 0.2932574682*height), control2: CGPoint(x: 0.196407564*width, y: 0.3316602017*height))
                path.addCurve(to: CGPoint(x: 0.1514309047*width, y: 0.391009922*height), control1: CGPoint(x: 0.1864127461*width, y: 0.3537708907*height), control2: CGPoint(x: 0.1634246834*width, y: 0.3742523433*height))
                path.addCurve(to: CGPoint(x: 0.0989581355*width, y: 0.4852712425*height), control1: CGPoint(x: 0.136438685*width, y: 0.4119568821*height), control2: CGPoint(x: 0.1139503553*width, y: 0.4747977625*height))
                path.addCurve(to: CGPoint(x: 0.0539814762*width, y: 0.4992358826*height), control1: CGPoint(x: 0.0869643569*width, y: 0.4936500052*height), control2: CGPoint(x: 0.063976287*width, y: 0.4980721803*height))
                path.addLine(to: CGPoint(x: 0.0239970367*width, y: 0.5132005227*height))
                path.addCurve(to: CGPoint(x: 0.0015087074*width, y: 0.5236740027*height), control1: CGPoint(x: 0.0165009268*width, y: 0.5166916827*height), control2: CGPoint(x: -0.0059874025*width, y: 0.5166916827*height))
                path.addCurve(to: CGPoint(x: 0.0239970367*width, y: 0.5236740027*height), control1: CGPoint(x: 0.0075055958*width, y: 0.52925988*height), control2: CGPoint(x: 0.0189996313*width, y: 0.5260014605*height))
                path.addLine(to: CGPoint(x: 0.053981462*width, y: 0.5166916827*height))
                path.addCurve(to: CGPoint(x: 0.0239970224*width, y: 0.576041403*height), control1: CGPoint(x: 0.0389892422*width, y: 0.5341474828*height), control2: CGPoint(x: 0.0120032464*width, y: 0.5704555256*height))
                path.addCurve(to: CGPoint(x: 0.1289425608*width, y: 0.5376386428*height), control1: CGPoint(x: 0.0314931323*width, y: 0.579532563*height), control2: CGPoint(x: 0.0689736817*width, y: 0.5934972031*height))
                path.addCurve(to: CGPoint(x: 0.1439347805*width, y: 0.5132005227*height), control1: CGPoint(x: 0.1314412688*width, y: 0.535311185*height), control2: CGPoint(x: 0.1379378984*width, y: 0.5271651627*height))
                path.addCurve(to: CGPoint(x: 0.1739192201*width, y: 0.4782889225*height), control1: CGPoint(x: 0.1499316627*width, y: 0.4992358826*height), control2: CGPoint(x: 0.1664231102*width, y: 0.4841075403*height))
                path.addCurve(to: CGPoint(x: 0.2788647584*width, y: 0.380536442*height), control1: CGPoint(x: 0.2064023677*width, y: 0.4515233446*height), control2: CGPoint(x: 0.2728678763*width, y: 0.394501082*height))
                path.addCurve(to: CGPoint(x: 0.308849198*width, y: 0.3107132416*height), control1: CGPoint(x: 0.2863608683*width, y: 0.3630806419*height), control2: CGPoint(x: 0.308849198*width, y: 0.3211867217*height))
                path.addCurve(to: CGPoint(x: 0.3388336375*width, y: 0.380536442*height), control1: CGPoint(x: 0.3188440016*width, y: 0.3281690417*height), control2: CGPoint(x: 0.3388336375*width, y: 0.3665718019*height))
                path.addCurve(to: CGPoint(x: 0.2938569782*width, y: 0.4573419624*height), control1: CGPoint(x: 0.3388336375*width, y: 0.394501082*height), control2: CGPoint(x: 0.308849198*width, y: 0.4375587311*height))
                path.addCurve(to: CGPoint(x: 0.2713686486*width, y: 0.5620767629*height), control1: CGPoint(x: 0.2863608683*width, y: 0.4747977625*height), control2: CGPoint(x: 0.2713686486*width, y: 0.5201828427*height))
                path.addCurve(to: CGPoint(x: 0.2938569782*width, y: 0.6598292434*height), control1: CGPoint(x: 0.2713686486*width, y: 0.6039706831*height), control2: CGPoint(x: 0.2863608683*width, y: 0.6447009011*height))
                path.addCurve(to: CGPoint(x: 0.308849198*width, y: 0.7156878037*height), control1: CGPoint(x: 0.2988543943*width, y: 0.6679752657*height), control2: CGPoint(x: 0.308849198*width, y: 0.6905514622*height))
                path.addCurve(to: CGPoint(x: 0.3013530881*width, y: 0.8099491242*height), control1: CGPoint(x: 0.308849198*width, y: 0.7471082439*height), control2: CGPoint(x: 0.2938569782*width, y: 0.7924933241*height))
                path.addCurve(to: CGPoint(x: 0.3463297474*width, y: 0.9077016047*height), control1: CGPoint(x: 0.308849198*width, y: 0.8274049243*height), control2: CGPoint(x: 0.3238414177*width, y: 0.8832634846*height))
                path.addCurve(to: CGPoint(x: 0.3463297474*width, y: 0.967051325*height), control1: CGPoint(x: 0.3538258573*width, y: 0.9146839247*height), control2: CGPoint(x: 0.3538258573*width, y: 0.960069005*height))
                path.addCurve(to: CGPoint(x: 0.3463297474*width, y: 0.9984717652*height), control1: CGPoint(x: 0.3388336375*width, y: 0.974033645*height), control2: CGPoint(x: 0.2713686486*width, y: 0.9984717652*height))
                path.addCurve(to: CGPoint(x: 0.436283066*width, y: 0.963560165*height), control1: CGPoint(x: 0.4212908462*width, y: 0.9984717652*height), control2: CGPoint(x: 0.4404207045*width, y: 0.9926871875*height))
                path.addCurve(to: CGPoint(x: 0.4287869561*width, y: 0.8727900045*height), control1: CGPoint(x: 0.4287869561*width, y: 0.9251574048*height), control2: CGPoint(x: 0.4287869561*width, y: 0.8867546446*height))
                path.addCurve(to: CGPoint(x: 0.4212908462*width, y: 0.775037524*height), control1: CGPoint(x: 0.4287869561*width, y: 0.8588253644*height), control2: CGPoint(x: 0.4137947363*width, y: 0.7959844841*height))
                path.addCurve(to: CGPoint(x: 0.4512752858*width, y: 0.7017231636*height), control1: CGPoint(x: 0.4287869561*width, y: 0.7540905639*height), control2: CGPoint(x: 0.4437791759*width, y: 0.7156878037*height))
                path.addCurve(to: CGPoint(x: 0.4737636154*width, y: 0.6284088032*height), control1: CGPoint(x: 0.4587713956*width, y: 0.6877585236*height), control2: CGPoint(x: 0.4662675055*width, y: 0.6458646033*height))
                path.addCurve(to: CGPoint(x: 0.4962519451*width, y: 0.5306563227*height), control1: CGPoint(x: 0.4797605262*width, y: 0.6144441632*height), control2: CGPoint(x: 0.4912545575*width, y: 0.5574219006*height))
                path.addLine(to: CGPoint(x: 0.5262363846*width, y: 0.6299370381*height))
                path.addCurve(to: CGPoint(x: 0.5487247142*width, y: 0.7032513985*height), control1: CGPoint(x: 0.5337324945*width, y: 0.6473928382*height), control2: CGPoint(x: 0.5412286044*width, y: 0.6892867584*height))
                path.addCurve(to: CGPoint(x: 0.5787091538*width, y: 0.7765657588*height), control1: CGPoint(x: 0.5562208241*width, y: 0.7172160385*height), control2: CGPoint(x: 0.5712130439*width, y: 0.7556187987*height))
                path.addCurve(to: CGPoint(x: 0.5712130439*width, y: 0.8743182394*height), control1: CGPoint(x: 0.5862052637*width, y: 0.797512719*height), control2: CGPoint(x: 0.5712130439*width, y: 0.8603535993*height))
                path.addCurve(to: CGPoint(x: 0.563716934*width, y: 0.9650883998*height), control1: CGPoint(x: 0.5712130439*width, y: 0.8882828794*height), control2: CGPoint(x: 0.5712130439*width, y: 0.9266856396*height))
                path.addCurve(to: CGPoint(x: 0.6536702526*width, y: height), control1: CGPoint(x: 0.5595792955*width, y: 0.9942154223*height), control2: CGPoint(x: 0.5787091538*width, y: height))
                path.addCurve(to: CGPoint(x: 0.6536702526*width, y: 0.9685795598*height), control1: CGPoint(x: 0.7286313514*width, y: height), control2: CGPoint(x: 0.6611663625*width, y: 0.9755618799*height))
                path.addCurve(to: CGPoint(x: 0.6536702526*width, y: 0.9092298395*height), control1: CGPoint(x: 0.6461741427*width, y: 0.9615972398*height), control2: CGPoint(x: 0.6461741427*width, y: 0.9162121596*height))
                path.addCurve(to: CGPoint(x: 0.6986469119*width, y: 0.811477359*height), control1: CGPoint(x: 0.6761585823*width, y: 0.8847917194*height), control2: CGPoint(x: 0.691150802*width, y: 0.8289331591*height))
                path.addCurve(to: CGPoint(x: 0.691150802*width, y: 0.7172160385*height), control1: CGPoint(x: 0.7061430218*width, y: 0.7940215589*height), control2: CGPoint(x: 0.691150802*width, y: 0.7486364787*height))
                path.addCurve(to: CGPoint(x: 0.7061430218*width, y: 0.6613574783*height), control1: CGPoint(x: 0.691150802*width, y: 0.6920796971*height), control2: CGPoint(x: 0.7011455771*width, y: 0.6695035005*height))
                path.addCurve(to: CGPoint(x: 0.7286313514*width, y: 0.5636049977*height), control1: CGPoint(x: 0.7136391317*width, y: 0.6462291359*height), control2: CGPoint(x: 0.7286313514*width, y: 0.605498918*height))
                path.addCurve(to: CGPoint(x: 0.7061430218*width, y: 0.4588701972*height), control1: CGPoint(x: 0.7286313514*width, y: 0.5217110775*height), control2: CGPoint(x: 0.7136391317*width, y: 0.4763259973*height))
                path.addCurve(to: CGPoint(x: 0.6611663625*width, y: 0.3820646768*height), control1: CGPoint(x: 0.691150802*width, y: 0.439086966*height), control2: CGPoint(x: 0.6611663625*width, y: 0.3960293169*height))
                path.addCurve(to: CGPoint(x: 0.691150802*width, y: 0.3122414764*height), control1: CGPoint(x: 0.6611663625*width, y: 0.3681000367*height), control2: CGPoint(x: 0.681156027*width, y: 0.3296972765*height))
                path.addCurve(to: CGPoint(x: 0.7211352416*width, y: 0.3820646768*height), control1: CGPoint(x: 0.691150802*width, y: 0.3227149565*height), control2: CGPoint(x: 0.7136391317*width, y: 0.3646088767*height))
                path.addCurve(to: CGPoint(x: 0.8260807799*width, y: 0.4798171573*height), control1: CGPoint(x: 0.7271321523*width, y: 0.3960293169*height), control2: CGPoint(x: 0.793597618*width, y: 0.4530515794*height))
                path.addCurve(to: CGPoint(x: 0.8560652195*width, y: 0.5147287575*height), control1: CGPoint(x: 0.8335768898*width, y: 0.4856357751*height), control2: CGPoint(x: 0.8500683087*width, y: 0.5007641174*height))
                path.addCurve(to: CGPoint(x: 0.8710574392*width, y: 0.5391668776*height), control1: CGPoint(x: 0.8620621302*width, y: 0.5286933976*height), control2: CGPoint(x: 0.8685587169*width, y: 0.5368394199*height))
                path.addCurve(to: CGPoint(x: 0.9760029776*width, y: 0.5775696378*height), control1: CGPoint(x: 0.9310263183*width, y: 0.5950254379*height), control2: CGPoint(x: 0.9685068677*width, y: 0.5810607978*height))
                path.addCurve(to: CGPoint(x: 0.946018538*width, y: 0.5182199175*height), control1: CGPoint(x: 0.9879967991*width, y: 0.5719837605*height), control2: CGPoint(x: 0.9610107578*width, y: 0.5356757176*height))
                path.addLine(to: CGPoint(x: 0.9760029776*width, y: 0.5252022375*height))
                path.addCurve(to: CGPoint(x: 0.9984913072*width, y: 0.5252022375*height), control1: CGPoint(x: 0.9810004223*width, y: 0.5275296953*height), control2: CGPoint(x: 0.9924943964*width, y: 0.5307881149*height))
                path.addCurve(to: CGPoint(x: 0.9760029776*width, y: 0.5147287575*height), control1: CGPoint(x: 1.0059874171*width, y: 0.5182199175*height), control2: CGPoint(x: 0.9834990875*width, y: 0.5182199175*height))
                path.addLine(to: CGPoint(x: 0.946018538*width, y: 0.5007641174*height))
                path.addCurve(to: CGPoint(x: 0.9010418787*width, y: 0.4867994773*height), control1: CGPoint(x: 0.9360237058*width, y: 0.4996004152*height), control2: CGPoint(x: 0.9130356431*width, y: 0.4951782401*height))
                path.addCurve(to: CGPoint(x: 0.8485691096*width, y: 0.3925381569*height), control1: CGPoint(x: 0.886049659*width, y: 0.4763259973*height), control2: CGPoint(x: 0.8635613293*width, y: 0.413485117*height))
                path.addCurve(to: CGPoint(x: 0.8035924503*width, y: 0.3471530766*height), control1: CGPoint(x: 0.8365753452*width, y: 0.3757805781*height), control2: CGPoint(x: 0.8135872825*width, y: 0.3552991255*height))
                path.addCurve(to: CGPoint(x: 0.7811041778*width, y: 0.2773299029*height), control1: CGPoint(x: 0.8035924503*width, y: 0.3331884366*height), control2: CGPoint(x: 0.7886002305*width, y: 0.294785703*height))
                path.addCurve(to: CGPoint(x: 0.6686625296*width, y: 0.1830685558*height), control1: CGPoint(x: 0.7910990101*width, y: 0.2505643516*height), control2: CGPoint(x: 0.7826034341*width, y: 0.1942402705*height))
                path.addCurve(to: CGPoint(x: 0.563716934*width, y: 0.1341923155*height), control1: CGPoint(x: 0.554721625*width, y: 0.1718968411*height), control2: CGPoint(x: 0.5512234366*width, y: 0.1458295111*height))
                path.addCurve(to: CGPoint(x: 0.6086935933*width, y: 0.0434221551*height), control1: CGPoint(x: 0.5862052637*width, y: 0.124882551*height), control2: CGPoint(x: 0.6266842113*width, y: 0.093694858*height))
                path.addCurve(to: CGPoint(x: 0.4962519451*width, y: 0), control1: CGPoint(x: 0.600650568*width, y: 0.0209469601*height), control2: CGPoint(x: 0.5682145885*width, y: 0))
                path.addCurve(to: CGPoint(x: 0.3913064353*width, y: 0.0418939202*height), control1: CGPoint(x: 0.4242893016*width, y: 0), control2: CGPoint(x: 0.3963038228*width, y: 0.0279292801*height))
                path.addCurve(to: CGPoint(x: 0.4362830946*width, y: 0.1326640807*height), control1: CGPoint(x: 0.3733157887*width, y: 0.0921666231*height), control2: CGPoint(x: 0.4137947649*width, y: 0.1233543162*height))
                path.addCurve(to: CGPoint(x: 0.3313374704*width, y: 0.1815403209*height), control1: CGPoint(x: 0.448776592*width, y: 0.1443012763*height), control2: CGPoint(x: 0.4452783464*width, y: 0.1703686062*height))
                path.closeSubpath()
                return path
        }
}

struct Deltoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0.2263920608*width, y: 0.268819348*height))
        path.addCurve(to: CGPoint(x: 0.3538259431*width, y: 0.1850315209*height), control1: CGPoint(x: 0.2203951728*width, y: 0.1973203925*height), control2: CGPoint(x: 0.3088492838*width, y: 0.1831695688*height))
        path.addCurve(to: CGPoint(x: 0.3838103826*width, y: 0.192013801*height), control1: CGPoint(x: 0.3663742864*width, y: 0.1850315209*height), control2: CGPoint(x: 0.3790440458*width, y: 0.1896863728*height))
        path.addCurve(to: CGPoint(x: 0.3088492838*width, y: 0.2827839615*height), control1: CGPoint(x: 0.2878601747*width, y: 0.2255289385*height), control2: CGPoint(x: 0.293857064*width, y: 0.2664918836*height))
        path.addLine(to: CGPoint(x: 0.2263920608*width, y: 0.268819348*height))
        path.closeSubpath()
        
        
        return path
    }
}


struct Bicep: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.2629178244*width, y: 0.3636010184*height))
        path.addLine(to: CGPoint(x: 0.2133279137*width, y: 0.3543628367*height))
        path.addCurve(to: CGPoint(x: 0.2043625584*width, y: 0.34790646*height), control1: CGPoint(x: 0.2076359916*width, y: 0.3533024799*height), control2: CGPoint(x: 0.2039273341*width, y: 0.3507543609*height))
        path.addCurve(to: CGPoint(x: 0.2236413701*width, y: 0.2793076907*height), control1: CGPoint(x: 0.2066141856*width, y: 0.3331728948*height), control2: CGPoint(x: 0.216666052*width, y: 0.2982616542*height))
        path.addCurve(to: CGPoint(x: 0.2411732322*width, y: 0.274142813*height), control1: CGPoint(x: 0.2250612081*width, y: 0.2754495838*height), control2: CGPoint(x: 0.2331163971*width, y: 0.2730281568*height))
        path.addCurve(to: CGPoint(x: 0.308849198*width, y: 0.2897662815*height), control1: CGPoint(x: 0.2680870452*width, y: 0.2778663177*height), control2: CGPoint(x: 0.308849198*width, y: 0.2851610094*height))
        path.addCurve(to: CGPoint(x: 0.2827251933*width, y: 0.3587923365*height), control1: CGPoint(x: 0.308849198*width, y: 0.2947001816*height), control2: CGPoint(x: 0.2932534582*width, y: 0.3363142516*height))
        path.addCurve(to: CGPoint(x: 0.2629178244*width, y: 0.3636010184*height), control1: CGPoint(x: 0.2807889279*width, y: 0.3629263095*height), control2: CGPoint(x: 0.2713530998*width, y: 0.3651724426*height))
        path.closeSubpath()
        
        
        return path
    }
}


// To use this shape, just add it to your SwiftUI View:
// Abs().fill().frame(width: 5.157065391540527, height: 18.472858428955078)

struct Abs: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.4839686238*width, y: 0.4058692464*height))
        path.addCurve(to: CGPoint(x: 0.450967342*width, y: 0.4118576385*height), control1: CGPoint(x: 0.4843114324*width, y: 0.4120971177*height), control2: CGPoint(x: 0.4621106402*width, y: 0.4124564564*height))
        path.addCurve(to: CGPoint(x: 0.4149659749*width, y: 0.4038731335*height), control1: CGPoint(x: 0.4218232584*width, y: 0.4118576385*height), control2: CGPoint(x: 0.4148230596*width, y: 0.4065346396*height))
        path.addLine(to: CGPoint(x: 0.4149659749*width, y: 0.3809957701*height))
        path.addCurve(to: CGPoint(x: 0.4227997392*width, y: 0.3774507798*height), control1: CGPoint(x: 0.4149659749*width, y: 0.3790054304*height), control2: CGPoint(x: 0.4185270223*width, y: 0.3774103739*height))
        path.addCurve(to: CGPoint(x: 0.4639429005*width, y: 0.3773423203*height), control1: CGPoint(x: 0.4321422918*width, y: 0.3775391362*height), control2: CGPoint(x: 0.4471759222*width, y: 0.377575427*height))
        path.addCurve(to: CGPoint(x: 0.4839686238*width, y: 0.4058692464*height), control1: CGPoint(x: 0.4926583553*width, y: 0.3769430951*height), control2: CGPoint(x: 0.4835401076*width, y: 0.3980844007*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4856476879*width, y: 0.3501189326*height))
        path.addCurve(to: CGPoint(x: 0.4415384411*width, y: 0.372134826*height), control1: CGPoint(x: 0.4853048148*width, y: 0.364650681*height), control2: CGPoint(x: 0.4786180975*width, y: 0.372134826*height))
        path.addCurve(to: CGPoint(x: 0.4085998405*width, y: 0.3636102609*height), control1: CGPoint(x: 0.4205375239*width, y: 0.372134826*height), control2: CGPoint(x: 0.4090285177*width, y: 0.3719939645*height))
        path.addCurve(to: CGPoint(x: 0.4458244039*width, y: 0.3343462524*height), control1: CGPoint(x: 0.4077289239*width, y: 0.3465776247*height), control2: CGPoint(x: 0.4069845548*width, y: 0.3407208882*height))
        path.addCurve(to: CGPoint(x: 0.4856476879*width, y: 0.3501189326*height), control1: CGPoint(x: 0.4788170535*width, y: 0.328931298*height), control2: CGPoint(x: 0.4860762827*width, y: 0.3319542436*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4689681113*width, y: 0.3283341814*height))
        path.addLine(to: CGPoint(x: 0.4458243754*width, y: 0.3315279834*height))
        path.addCurve(to: CGPoint(x: 0.4098227795*width, y: 0.3176407193*height), control1: CGPoint(x: 0.4098228009*width, y: 0.3370674685*height), control2: CGPoint(x: 0.4106495653*width, y: 0.336217848*height))
        path.addCurve(to: CGPoint(x: 0.4591106228*width, y: 0.2857028325*height), control1: CGPoint(x: 0.4085998323*width, y: 0.2901622056*height), control2: CGPoint(x: 0.4261092802*width, y: 0.2922900279*height))
        path.addCurve(to: CGPoint(x: 0.4839686238*width, y: 0.3050651705*height), control1: CGPoint(x: 0.4921119653*width, y: 0.2791156371*height), control2: CGPoint(x: 0.4839686238*width, y: 0.2847047477*height))
        path.addCurve(to: CGPoint(x: 0.4689681113*width, y: 0.3283341814*height), control1: CGPoint(x: 0.4839686238*width, y: 0.3213535078*height), control2: CGPoint(x: 0.4839686595*width, y: 0.3264071741*height))
        path.closeSubpath()
        return path
    }
}

struct Forearm: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.1162516765*width, y: 0.4848220092*height))
        path.addLine(to: CGPoint(x: 0.1350989338*width, y: 0.4906738148*height))
        path.addCurve(to: CGPoint(x: 0.1584826709*width, y: 0.4872265499*height), control1: CGPoint(x: 0.1433241421*width, y: 0.4932276338*height), control2: CGPoint(x: 0.154652154*width, y: 0.4914708136*height))
        path.addCurve(to: CGPoint(x: 0.2298502585*width, y: 0.4244011714*height), control1: CGPoint(x: 0.1738092065*width, y: 0.4702445277*height), control2: CGPoint(x: 0.2047843047*width, y: 0.4419121069*height))
        path.addCurve(to: CGPoint(x: 0.2717873709*width, y: 0.3753180804*height), control1: CGPoint(x: 0.2525777028*width, y: 0.4085239106*height), control2: CGPoint(x: 0.2628743165*width, y: 0.3898683988*height))
        path.addCurve(to: CGPoint(x: 0.2633086948*width, y: 0.3668457474*height), control1: CGPoint(x: 0.2738780513*width, y: 0.371905097*height), control2: CGPoint(x: 0.2702904022*width, y: 0.3682683169*height))
        path.addLine(to: CGPoint(x: 0.2117620588*width, y: 0.3563427819*height))
        path.addCurve(to: CGPoint(x: 0.1932521771*width, y: 0.3590831156*height), control1: CGPoint(x: 0.2049490928*width, y: 0.3549545947*height), control2: CGPoint(x: 0.1969849836*width, y: 0.3560876716*height))
        path.addCurve(to: CGPoint(x: 0.1439347805*width, y: 0.4189391489*height), control1: CGPoint(x: 0.1774264732*width, y: 0.3717826839*height), control2: CGPoint(x: 0.1490825905*width, y: 0.3973617646*height))
        path.addCurve(to: CGPoint(x: 0.1105266579*width, y: 0.4766387506*height), control1: CGPoint(x: 0.1386614582*width, y: 0.4410426263*height), control2: CGPoint(x: 0.1214090732*width, y: 0.4629661415*height))
        path.addCurve(to: CGPoint(x: 0.1162516765*width, y: 0.4848220092*height), control1: CGPoint(x: 0.1081243601*width, y: 0.4796569851*height), control2: CGPoint(x: 0.1105008925*width, y: 0.4830364627*height))
        path.closeSubpath()
        
        return path
    }
}

struct Chest: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.3933300166*width, y: 0.1955047746*height))
        path.addCurve(to: CGPoint(x: 0.3165030686*width, y: 0.282783775*height), control1: CGPoint(x: 0.301137679*width, y: 0.223434053*height), control2: CGPoint(x: 0.3036985776*width, y: 0.2653279749*height))
        path.addCurve(to: CGPoint(x: 0.4932050491*width, y: 0.2758016414*height), control1: CGPoint(x: 0.4148415564*width, y: 0.2911625777*height), control2: CGPoint(x: 0.4727178534*width, y: 0.2816202592*height))
        path.addLine(to: CGPoint(x: 0.4932050491*width, y: 0.2164519211*height))
        path.addCurve(to: CGPoint(x: 0.3933300166*width, y: 0.1955047746*height), control1: CGPoint(x: 0.4829614512*width, y: 0.2152882006*height), control2: CGPoint(x: 0.424060803*width, y: 0.188522626*height))
        path.closeSubpath()
        
        return path
    }
}


struct Obliques: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0.3238414177*width, y: 0.4294126822*height))
        path.addCurve(to: CGPoint(x: 0.4212908462*width, y: 0.4538508023*height), control1: CGPoint(x: 0.3178445297*width, y: 0.4405843969*height), control2: CGPoint(x: 0.3913064067*width, y: 0.4503596423*height))
        path.addCurve(to: CGPoint(x: 0.3988025166*width, y: 0.2897662815*height), control1: CGPoint(x: 0.4092970676*width, y: 0.4343003116*height), control2: CGPoint(x: 0.3838102968*width, y: 0.3421336818*height))
        path.addCurve(to: CGPoint(x: 0.332993887*width, y: 0.2870856911*height), control1: CGPoint(x: 0.3940058329*width, y: 0.2897662815*height), control2: CGPoint(x: 0.3585156799*width, y: 0.2882772374*height))
        path.addCurve(to: CGPoint(x: 0.3163453079*width, y: 0.2940762149*height), control1: CGPoint(x: 0.3241029163*width, y: 0.2866705947*height), control2: CGPoint(x: 0.3163453079*width, y: 0.2899146729*height))
        path.addLine(to: CGPoint(x: 0.3163453079*width, y: 0.2956270898*height))
        path.addCurve(to: CGPoint(x: 0.3204186068*width, y: 0.3115951676*height), control1: CGPoint(x: 0.3163453079*width, y: 0.3010115791*height), control2: CGPoint(x: 0.3176665*width, y: 0.306365456*height))
        path.addCurve(to: CGPoint(x: 0.3538258573*width, y: 0.380536442*height), control1: CGPoint(x: 0.3322977858*width, y: 0.3341686623*height), control2: CGPoint(x: 0.3538258573*width, y: 0.3731211229*height))
        path.addCurve(to: CGPoint(x: 0.3238414177*width, y: 0.4294126822*height), control1: CGPoint(x: 0.3538258573*width, y: 0.391009922*height), control2: CGPoint(x: 0.3313375267*width, y: 0.4154480421*height))
        path.closeSubpath()
        
        return path
    }
}


struct Quads: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.330061058*width, y: 0.6926979056*height))
        path.addLine(to: CGPoint(x: 0.4099256943*width, y: 0.7112955136*height))
        path.addCurve(to: CGPoint(x: 0.431498228*width, y: 0.7059479701*height), control1: CGPoint(x: 0.4191517967*width, y: 0.7134439546*height), control2: CGPoint(x: 0.430172174*width, y: 0.7107121709*height))
        path.addLine(to: CGPoint(x: 0.4808182697*width, y: 0.5287523684*height))
        path.addCurve(to: CGPoint(x: 0.480146564*width, y: 0.5256437466*height), control1: CGPoint(x: 0.4811090276*width, y: 0.5277077665*height), control2: CGPoint(x: 0.4808906732*width, y: 0.5266384603*height))
        path.addCurve(to: CGPoint(x: 0.3088495411*width, y: 0.4608331224*height), control1: CGPoint(x: 0.4390736043*width, y: 0.4707381156*height), control2: CGPoint(x: 0.3196066514*width, y: 0.4400771017*height))
        path.addCurve(to: CGPoint(x: 0.3222485401*width, y: 0.6881321655*height), control1: CGPoint(x: 0.2678524701*width, y: 0.5399376406*height), control2: CGPoint(x: 0.2997854102*width, y: 0.6432403868*height))
        path.addCurve(to: CGPoint(x: 0.330061058*width, y: 0.6926979056*height), control1: CGPoint(x: 0.323249436*width, y: 0.6901324069*height), control2: CGPoint(x: 0.32611666*width, y: 0.6917794091*height))
        path.closeSubpath()
        
        
        return path
    }
}

struct FrontCalf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0.3761743841*width, y: 0.9261363104*height))
        path.addLine(to: CGPoint(x: 0.3998038413*width, y: 0.9292805705*height))
        path.addCurve(to: CGPoint(x: 0.4189527442*width, y: 0.9217847192*height), control1: CGPoint(x: 0.4100543092*width, y: 0.9306445446*height), control2: CGPoint(x: 0.4200059481*width, y: 0.9267254063*height))
        path.addCurve(to: CGPoint(x: 0.4196949375*width, y: 0.7275738675*height), control1: CGPoint(x: 0.4007694934*width, y: 0.8364854376*height), control2: CGPoint(x: 0.4104490185*width, y: 0.7585699952*height))
        path.addCurve(to: CGPoint(x: 0.4118471043*width, y: 0.7203018605*height), control1: CGPoint(x: 0.4205775557*width, y: 0.7246149734*height), control2: CGPoint(x: 0.4174946724*width, y: 0.7217181482*height))
        path.addLine(to: CGPoint(x: 0.3449316044*width, y: 0.7035208958*height))
        path.addCurve(to: CGPoint(x: 0.3228597094*width, y: 0.709367321*height), control1: CGPoint(x: 0.3351841652*width, y: 0.7010764488*height), control2: CGPoint(x: 0.3233081843*width, y: 0.7042155934*height))
        path.addCurve(to: CGPoint(x: 0.3163453079*width, y: 0.7994756441*height), control1: CGPoint(x: 0.3202277678*width, y: 0.7396010026*height), control2: CGPoint(x: 0.3163453079*width, y: 0.7871672555*height))
        path.addCurve(to: CGPoint(x: 0.3662820377*width, y: 0.9218034705*height), control1: CGPoint(x: 0.3163453079*width, y: 0.8130437092*height), control2: CGPoint(x: 0.3375745307*width, y: 0.8826385906*height))
        path.addCurve(to: CGPoint(x: 0.3761743841*width, y: 0.9261363104*height), control1: CGPoint(x: 0.3678346065*width, y: 0.9239216004*height), control2: CGPoint(x: 0.371553605*width, y: 0.9255214313*height))
        path.closeSubpath()
        
        return path
    }
}

struct LowerBack: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0.3808618834*width, y: 0.3986435584*height))
        path.addLine(to: CGPoint(x: 0.479691983*width, y: 0.4872691134*height))
        path.addCurve(to: CGPoint(x: 0.5063017376*width, y: 0.4872691134*height), control1: CGPoint(x: 0.4852887442*width, y: 0.4922879888*height), control2: CGPoint(x: 0.5007049764*width, y: 0.4922879888*height))
        path.addLine(to: CGPoint(x: 0.6051318087*width, y: 0.3986435584*height))
        path.addCurve(to: CGPoint(x: 0.6036726432*width, y: 0.3911456029*height), control1: CGPoint(x: 0.6078280537*width, y: 0.3962257133*height), control2: CGPoint(x: 0.6072583335*width, y: 0.3932982856*height))
        path.addLine(to: CGPoint(x: 0.5256191245*width, y: 0.3442858517*height))
        path.addCurve(to: CGPoint(x: 0.5052009867*width, y: 0.3428373634*height), control1: CGPoint(x: 0.5207263532*width, y: 0.3413484564*height), control2: CGPoint(x: 0.511749717*width, y: 0.3407116466*height))
        path.addLine(to: CGPoint(x: 0.501569315*width, y: 0.3440161946*height))
        path.addCurve(to: CGPoint(x: 0.4844243771*width, y: 0.3440161946*height), control1: CGPoint(x: 0.4964181987*width, y: 0.3456882458*height), control2: CGPoint(x: 0.4895754934*width, y: 0.3456882454*height))
        path.addLine(to: CGPoint(x: 0.4807927054*width, y: 0.3428373634*height))
        path.addCurve(to: CGPoint(x: 0.4603745676*width, y: 0.3442858517*height), control1: CGPoint(x: 0.4742439751*width, y: 0.3407116474*height), control2: CGPoint(x: 0.4652673389*width, y: 0.3413484566*height))
        path.addLine(to: CGPoint(x: 0.3823210489*width, y: 0.3911456029*height))
        path.addCurve(to: CGPoint(x: 0.3808618834*width, y: 0.3986435584*height), control1: CGPoint(x: 0.3787353577*width, y: 0.3932982856*height), control2: CGPoint(x: 0.3781656386*width, y: 0.3962257133*height))
        path.closeSubpath()
        
        return path
    }
}

struct RearDeltoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.2286865977*width, y: 0.2703131965*height))
        path.addCurve(to: CGPoint(x: 0.321723443*width, y: 0.1911474035*height), control1: CGPoint(x: 0.2286865977*width, y: 0.1982634601*height), control2: CGPoint(x: 0.3046363464*width, y: 0.1911473749*height))
        path.addCurve(to: CGPoint(x: 0.372869043*width, y: 0.2213278442*height), control1: CGPoint(x: 0.3342717864*width, y: 0.1911474035*height), control2: CGPoint(x: 0.3681027062*width, y: 0.2190004164*height))
        path.addCurve(to: CGPoint(x: 0.3046363536*width, y: 0.2855061298*height), control1: CGPoint(x: 0.276918835*width, y: 0.254842985*height), control2: CGPoint(x: 0.315620908*width, y: 0.265042796*height))
        path.addLine(to: CGPoint(x: 0.2286865977*width, y: 0.2703131965*height))
        path.closeSubpath()
        
        return path
    }
}
struct Tricep: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.2589777228*width, y: 0.3644967149*height))
        path.addLine(to: CGPoint(x: 0.2138939309*width, y: 0.355454277*height))
        path.addCurve(to: CGPoint(x: 0.2053145133*width, y: 0.3490663533*height), control1: CGPoint(x: 0.2083945089*width, y: 0.3543512636*height), control2: CGPoint(x: 0.2048504506*width, y: 0.3518466202*height))
        path.addCurve(to: CGPoint(x: 0.2256317379*width, y: 0.282672945*height), control1: CGPoint(x: 0.2077079199*width, y: 0.3347270859*height), control2: CGPoint(x: 0.2184707884*width, y: 0.3013045631*height))
        path.addCurve(to: CGPoint(x: 0.2431773687*width, y: 0.2776098147*height), control1: CGPoint(x: 0.2271126628*width, y: 0.2788198223*height), control2: CGPoint(x: 0.2351804571*width, y: 0.2764051968*height))
        path.addCurve(to: CGPoint(x: 0.3054689083*width, y: 0.2936147026*height), control1: CGPoint(x: 0.2687776382*width, y: 0.2814661208*height), control2: CGPoint(x: 0.3054689083*width, y: 0.2890327199*height))
        path.addCurve(to: CGPoint(x: 0.2791962362*width, y: 0.3597565393*height), control1: CGPoint(x: 0.3054689083*width, y: 0.2985254882*height), control2: CGPoint(x: 0.2897797903*width, y: 0.3377062129*height))
        path.addCurve(to: CGPoint(x: 0.2589777228*width, y: 0.3644967149*height), control1: CGPoint(x: 0.2771798037*width, y: 0.3639576802*height), control2: CGPoint(x: 0.2674671365*width, y: 0.3661994318*height))
        path.closeSubpath()
        
        return path
    }
}
struct RearForearm: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.1190126329*width, y: 0.4867982521*height))
        path.addLine(to: CGPoint(x: 0.1337914524*width, y: 0.4912137151*height))
        path.addCurve(to: CGPoint(x: 0.157006248*width, y: 0.4877080121*height), control1: CGPoint(x: 0.1420199564*width, y: 0.4936721526*height), control2: CGPoint(x: 0.1531409019*width, y: 0.4918900421*height))
        path.addCurve(to: CGPoint(x: 0.2173872295*width, y: 0.4329039221*height), control1: CGPoint(x: 0.1708302567*width, y: 0.4727514417*height), control2: CGPoint(x: 0.196288693*width, y: 0.4507975422*height))
        path.addCurve(to: CGPoint(x: 0.272692272*width, y: 0.3759060843*height), control1: CGPoint(x: 0.2371320674*width, y: 0.416158376*height), control2: CGPoint(x: 0.2604825409*width, y: 0.3918488567*height))
        path.addCurve(to: CGPoint(x: 0.2639563232*width, y: 0.3673656711*height), control1: CGPoint(x: 0.2753560898*width, y: 0.3724278225*height), control2: CGPoint(x: 0.2713807158*width, y: 0.3686623308*height))
        path.addLine(to: CGPoint(x: 0.2080152335*width, y: 0.3575956596*height))
        path.addCurve(to: CGPoint(x: 0.1907109477*width, y: 0.360598299*height), control1: CGPoint(x: 0.2013365871*width, y: 0.3564292444*height), control2: CGPoint(x: 0.1938580706*width, y: 0.3576171785*height))
        path.addCurve(to: CGPoint(x: 0.145362291*width, y: 0.4227563267*height), control1: CGPoint(x: 0.1768728022*width, y: 0.3737065316*height), control2: CGPoint(x: 0.1549388907*width, y: 0.4013479176*height))
        path.addCurve(to: CGPoint(x: 0.112904772*width, y: 0.4785169218*height), control1: CGPoint(x: 0.1351947319*width, y: 0.4454858168*height), control2: CGPoint(x: 0.122592093*width, y: 0.4653314682*height))
        path.addCurve(to: CGPoint(x: 0.1190126329*width, y: 0.4867982521*height), control1: CGPoint(x: 0.1106352346*width, y: 0.4816060066*height), control2: CGPoint(x: 0.1131120931*width, y: 0.4850353458*height))
        path.closeSubpath()
        
        return path
    }
}
struct Trapezius : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.4380103419*width, y: 0.1599907873*height))
        path.addCurve(to: CGPoint(x: 0.3306981061*width, y: 0.1869079741*height), control1: CGPoint(x: 0.4153164901*width, y: 0.1793676417*height), control2: CGPoint(x: 0.3572972518*width, y: 0.1859916885*height))
        path.addCurve(to: CGPoint(x: 0.3298827086*width, y: 0.1870013047*height), control1: CGPoint(x: 0.3304127295*width, y: 0.1869178026*height), control2: CGPoint(x: 0.3301457281*width, y: 0.1869488063*height))
        path.addCurve(to: CGPoint(x: 0.3303348017*width, y: 0.1905322581*height), control1: CGPoint(x: 0.3273633314*width, y: 0.1875041618*height), control2: CGPoint(x: 0.3278520624*width, y: 0.189991319*height))
        path.addCurve(to: CGPoint(x: 0.4102856531*width, y: 0.2614439156*height), control1: CGPoint(x: 0.3523267011*width, y: 0.1953238534*height), control2: CGPoint(x: 0.3874702136*width, y: 0.2135041373*height))
        path.addCurve(to: CGPoint(x: 0.4734314514*width, y: 0.3363476924*height), control1: CGPoint(x: 0.429895871*width, y: 0.3026488703*height), control2: CGPoint(x: 0.455058127*width, y: 0.3254351272*height))
        path.addCurve(to: CGPoint(x: 0.491120388*width, y: 0.3327685023*height), control1: CGPoint(x: 0.4803295173*width, y: 0.3404447021*height), control2: CGPoint(x: 0.4911038312*width, y: 0.3379748779*height))
        path.addCurve(to: CGPoint(x: 0.4910833855*width, y: 0.1053905916*height), control1: CGPoint(x: 0.4913793192*width, y: 0.2513297875*height), control2: CGPoint(x: 0.4916879636*width, y: 0.1076431668*height))
        path.addCurve(to: CGPoint(x: 0.4554373162*width, y: 0.1028081728*height), control1: CGPoint(x: 0.4902912503*width, y: 0.1024392271*height), control2: CGPoint(x: 0.4641508033*width, y: 0.1005946483*height))
        path.addCurve(to: CGPoint(x: 0.4443531139*width, y: 0.1268976018*height), control1: CGPoint(x: 0.449668711*width, y: 0.1042735969*height), control2: CGPoint(x: 0.4460338366*width, y: 0.1172932893*height))
        path.addCurve(to: CGPoint(x: 0.4510455218*width, y: 0.1362292473*height), control1: CGPoint(x: 0.4437951607*width, y: 0.1300859418*height), control2: CGPoint(x: 0.4488795926*width, y: 0.1331935466*height))
        path.addCurve(to: CGPoint(x: 0.4380103419*width, y: 0.1599907873*height), control1: CGPoint(x: 0.4539102509*width, y: 0.1402443363*height), control2: CGPoint(x: 0.4525031932*width, y: 0.1476162562*height))
        path.closeSubpath()
        
        return path
    }
}
struct Lats: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.3122513917*width, y: 0.2831896724*height))
        path.addCurve(to: CGPoint(x: 0.3648069159*width, y: 0.3827970448*height), control1: CGPoint(x: 0.3193180551*width, y: 0.3052806545*height), control2: CGPoint(x: 0.3468306671*width, y: 0.3532207158*height))
        path.addCurve(to: CGPoint(x: 0.3835725833*width, y: 0.3847891091*height), control1: CGPoint(x: 0.3675319529*width, y: 0.3872805546*height), control2: CGPoint(x: 0.3772149846*width, y: 0.3883870906*height))
        path.addCurve(to: CGPoint(x: 0.4545029618*width, y: 0.3427490136*height), control1: CGPoint(x: 0.4012594468*width, y: 0.3747794852*height), control2: CGPoint(x: 0.4323739904*width, y: 0.3561429229*height))
        path.addCurve(to: CGPoint(x: 0.4533462783*width, y: 0.3312536118*height), control1: CGPoint(x: 0.4598481693*width, y: 0.3395137469*height), control2: CGPoint(x: 0.4583439661*width, y: 0.3346072064*height))
        path.addCurve(to: CGPoint(x: 0.4097421405*width, y: 0.2811364531*height), control1: CGPoint(x: 0.4365210082*width, y: 0.319963376*height), control2: CGPoint(x: 0.4192854301*width, y: 0.2964601381*height))
        path.addCurve(to: CGPoint(x: 0.3951645253*width, y: 0.2759939493*height), control1: CGPoint(x: 0.4078550449*width, y: 0.2781063413*height), control2: CGPoint(x: 0.4019388303*width, y: 0.2759939493*height))
        path.addLine(to: CGPoint(x: 0.3262027964*width, y: 0.2759939493*height))
        path.addCurve(to: CGPoint(x: 0.3122513917*width, y: 0.2831896724*height), control1: CGPoint(x: 0.3176877756*width, y: 0.2759939493*height), control2: CGPoint(x: 0.3109966572*width, y: 0.2792672672*height))
        path.closeSubpath()
        
        return path
    }
}
struct Glute: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.293555783*width, y: 0.4890694558*height))
        path.addCurve(to: CGPoint(x: 0.2991913624*width, y: 0.5564818828*height), control1: CGPoint(x: 0.2925852386*width, y: 0.4944936694*height), control2: CGPoint(x: 0.2952051003*width, y: 0.5286946561*height))
        path.addCurve(to: CGPoint(x: 0.3397923837*width, y: 0.5633187201*height), control1: CGPoint(x: 0.3001967182*width, y: 0.5634899726*height), control2: CGPoint(x: 0.3282360359*width, y: 0.5678314956*height))
        path.addCurve(to: CGPoint(x: 0.3844592406*width, y: 0.5476930409*height), control1: CGPoint(x: 0.3571225983*width, y: 0.5565512548*height), control2: CGPoint(x: 0.3757672143*width, y: 0.5501990226*height))
        path.addCurve(to: CGPoint(x: 0.479374803*width, y: 0.5166199801*height), control1: CGPoint(x: 0.3971153957*width, y: 0.5440441591*height), control2: CGPoint(x: 0.4495692705*width, y: 0.5266084088*height))
        path.addCurve(to: CGPoint(x: 0.4855881523*width, y: 0.5109622936*height), control1: CGPoint(x: 0.4832854084*width, y: 0.5153094566*height), control2: CGPoint(x: 0.4855881523*width, y: 0.5132060761*height))
        path.addLine(to: CGPoint(x: 0.4855881523*width, y: 0.5027394547*height))
        path.addCurve(to: CGPoint(x: 0.4837808664*width, y: 0.4994159381*height), control1: CGPoint(x: 0.4855881523*width, y: 0.5015788755*height), control2: CGPoint(x: 0.4849670175*width, y: 0.5004366081*height))
        path.addLine(to: CGPoint(x: 0.4060925967*width, y: 0.4325659184*height))
        path.addCurve(to: CGPoint(x: 0.3898437811*width, y: 0.4296160171*height), control1: CGPoint(x: 0.4028735279*width, y: 0.4297959387*height), control2: CGPoint(x: 0.3960019055*width, y: 0.4283141314*height))
        path.addCurve(to: CGPoint(x: 0.293555783*width, y: 0.4890694558*height), control1: CGPoint(x: 0.3416566673*width, y: 0.4398032353*height), control2: CGPoint(x: 0.2950614655*width, y: 0.480654439*height))
        path.closeSubpath()
        
        return path
    }
}
struct Hamstring: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.4280193987*width, y: 0.6898400297*height))
        path.addLine(to: CGPoint(x: 0.3371328409*width, y: 0.6898400297*height))
        path.addCurve(to: CGPoint(x: 0.3225012948*width, y: 0.6843800847*height), control1: CGPoint(x: 0.3301123331*width, y: 0.6898400297*height), control2: CGPoint(x: 0.3240319738*width, y: 0.6875710767*height))
        path.addLine(to: CGPoint(x: 0.309180447*width, y: 0.656610191*height))
        path.addCurve(to: CGPoint(x: 0.3038670804*width, y: 0.5873222031*height), control1: CGPoint(x: 0.2818548175*width, y: 0.6049977589*height), control2: CGPoint(x: 0.2977947189*width, y: 0.5975739898*height))
        path.addCurve(to: CGPoint(x: 0.4722662178*width, y: 0.5272308457*height), control1: CGPoint(x: 0.3090570936*width, y: 0.5785600599*height), control2: CGPoint(x: 0.433272672*width, y: 0.5373119508*height))
        path.addCurve(to: CGPoint(x: 0.4822905319*width, y: 0.5309072818*height), control1: CGPoint(x: 0.4793515549*width, y: 0.5253990541*height), control2: CGPoint(x: 0.4832409855*width, y: 0.5271591435*height))
        path.addCurve(to: CGPoint(x: 0.4428838828*width, y: 0.6837436576*height), control1: CGPoint(x: 0.4765831351*width, y: 0.553414689*height), control2: CGPoint(x: 0.4555844537*width, y: 0.6360538463*height))
        path.addCurve(to: CGPoint(x: 0.4280193987*width, y: 0.6898400297*height), control1: CGPoint(x: 0.4419532316*width, y: 0.6872382269*height), control2: CGPoint(x: 0.43558032*width, y: 0.6898400297*height))
        path.closeSubpath()
        
        return path
    }
}


struct RearCalf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.4012099053*width, y: 0.8795093795*height))
        path.addLine(to: CGPoint(x: 0.3530613881*width, y: 0.8795093795*height))
        path.addCurve(to: CGPoint(x: 0.3382492907*width, y: 0.8736061676*height), control1: CGPoint(x: 0.3456759638*width, y: 0.8795093795*height), control2: CGPoint(x: 0.3393906721*width, y: 0.8770044498*height))
        path.addLine(to: CGPoint(x: 0.3115033077*width, y: 0.7939741479*height))
        path.addCurve(to: CGPoint(x: 0.3121890823*width, y: 0.7899706286*height), control1: CGPoint(x: 0.3110537542*width, y: 0.7926356705*height), control2: CGPoint(x: 0.3114665708*width, y: 0.7912829233*height))
        path.addCurve(to: CGPoint(x: 0.323350778*width, y: 0.7005368745*height), control1: CGPoint(x: 0.3189957037*width, y: 0.7776077638*height), control2: CGPoint(x: 0.3227952831*width, y: 0.7295046404*height))
        path.addCurve(to: CGPoint(x: 0.3384141717*width, y: 0.6935718675*height), control1: CGPoint(x: 0.323424723*width, y: 0.696680799*height), control2: CGPoint(x: 0.3301341979*width, y: 0.6935718675*height))
        path.addLine(to: CGPoint(x: 0.4248041616*width, y: 0.6935718675*height))
        path.addCurve(to: CGPoint(x: 0.4395287857*width, y: 0.7019544658*height), control1: CGPoint(x: 0.4342983029*width, y: 0.6935718675*height), control2: CGPoint(x: 0.4414068594*width, y: 0.6976201381*height))
        path.addCurve(to: CGPoint(x: 0.4064216724*width, y: 0.7919230061*height), control1: CGPoint(x: 0.4272739526*width, y: 0.7302368519*height), control2: CGPoint(x: 0.4064216724*width, y: 0.7807130695*height))
        path.addCurve(to: CGPoint(x: 0.4161267762*width, y: 0.8722079669*height), control1: CGPoint(x: 0.4064216724*width, y: 0.8032831532*height), control2: CGPoint(x: 0.4129519015*width, y: 0.8449373279*height))
        path.addCurve(to: CGPoint(x: 0.4012099053*width, y: 0.8795093795*height), control1: CGPoint(x: 0.4165901216*width, y: 0.8761878606*height), control2: CGPoint(x: 0.4097679693*width, y: 0.8795093795*height))
        path.closeSubpath()
        return path
    }
}
