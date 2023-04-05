# !python yolov5/detect.py --weights model_weights/best-12-Apr-2022_0104.pt --img 416 --conf 0.4 --source validation_data/videos/polaryzacja.avi
import argparse
from pathlib import WindowsPath

from yolov5.detect2 import main as detect_script_main
from yolov5.utils.general import print_args

name="Dodmac_best2model_video"
if __name__ == "__main__":
    opt = argparse.Namespace(
        weights=['model_weights/best2.pt'],
        source='.\\validation_data\\videos\\Dodmac.avi',
        #source='.\\validation_data\\images\\BHDC',
        data=WindowsPath('yolov5/data/coco128.yaml'),
        imgsz=[964, 1288], conf_thres=0.1, iou_thres=0.3, max_det=2500, device='', view_img=False,
        save_txt=True, save_conf=False, save_crop=False, nosave=False, classes=None, agnostic_nms=
        False, augment=False, visualize=False, update=False,
        project=WindowsPath('yolov5/runs/detect'),
        name=name, exist_ok=False, line_thickness=2, hide_labels=True, hide_conf=False,
        half=False, dnn=False
    )

    opt.imgsz *= 2 if len(opt.imgsz) == 1 else 1  # expand
    print_args(vars(opt))
    detect_script_main(opt)
