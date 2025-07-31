use crate::rustaops;
use image::buffer::ConvertBuffer;
use image::imageops;
use image::DynamicImage;
use image::DynamicImage::ImageRgba8;
use image::RgbaImage;

/// All available image filters.
///
///
/// Use [`FromStr`](std::str::FromStr) to parse it from a string.
/// It parses from the (lowercase) names given below.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum FilterType {
    /// The `1977` filter.
    NineTeenSeventySeven,
    /// The `aden` filter.
    Aden,
    /// The `brannan` filter.
    Brannan,
    /// The `brooklyn` filter.
    Brooklyn,
    /// The `clarendon` filter.
    Clarendon,
    /// The `earlybird` filter.
    Earlybird,
    /// The `gingham` filter.
    Gingham,
    /// The `hudson` filter.
    Hudson,
    /// The `Inkwell` filter.
    Inkwell,
    /// The `kelvin` filter.
    Kelvin,
    /// The `lark` filter.
    Lark,
    /// The `lofi` filter.
    Lofi,
    /// The `maven` filter.
    Maven,
    /// The `mayfair` filter.
    Mayfair,
    /// The `moon` filter.
    Moon,
    /// The `nashville` filter.
    Nashville,
    /// The `reyes` filter.
    Reyes,
    /// The `rise` filter.
    Rise,
    /// The `slumber` filter.
    Slumber,
    /// The `stinson` filter.
    Stinson,
    /// The `toaster` filter.
    Toaster,
    /// The `valencia` filter.
    Valencia,
    /// The `walden` filter.
    Walden,
}

/// Apply a given filter type.
pub trait RustagramFilter {
    /// Apply the given filter to an image.
    fn apply_filter(&self, ft: FilterType) -> Self;
}

impl RustagramFilter for DynamicImage {
    /// Apply a filter to a `DynamicImage`.
    ///
    /// This always returns an `DynamicImage::RgbaImage`.
    fn apply_filter(&self, ft: FilterType) -> DynamicImage {
        ImageRgba8(self.to_rgba8().apply_filter(ft))
    }
}

impl RustagramFilter for RgbaImage {
    /// Apply a filter to a `RgbaImage`.
    fn apply_filter(&self, ft: FilterType) -> RgbaImage {
        match ft {
            FilterType::NineTeenSeventySeven => apply_1977(self),
            FilterType::Aden => apply_aden(self),
            FilterType::Brannan => apply_brannan(self),
            FilterType::Brooklyn => apply_brooklyn(self),
            FilterType::Clarendon => apply_clarendon(self),
            FilterType::Earlybird => apply_earlybird(self),
            FilterType::Gingham => apply_gingham(self),
            FilterType::Hudson => apply_hudson(self),
            FilterType::Inkwell => apply_inkwell(self),
            FilterType::Kelvin => apply_kelvin(self),
            FilterType::Lark => apply_lark(self),
            FilterType::Lofi => apply_lofi(self),
            FilterType::Maven => apply_maven(self),
            FilterType::Mayfair => apply_mayfair(self),
            FilterType::Moon => apply_moon(self),
            FilterType::Nashville => apply_nashville(self),
            FilterType::Reyes => apply_reyes(self),
            FilterType::Rise => apply_rise(self),
            FilterType::Slumber => apply_slumber(self),
            FilterType::Stinson => apply_stinson(self),
            FilterType::Toaster => apply_toaster(self),
            FilterType::Valencia => apply_valencia(self),
            FilterType::Walden => apply_walden(self),
        }
    }
}

pub fn apply_1977(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, 10.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, 10.0);
    let saturated = rustaops::saturate(&brightened, 30.0);
    let foreground = rustaops::fill_with_channels(width, height, &[243, 106, 188, 76]);

    rustaops::blend_screen(&saturated, &foreground)
}

pub fn apply_aden(img: &RgbaImage) -> RgbaImage {
    let huerotated = imageops::huerotate(img, -20);
    let contrasted = imageops::contrast(&huerotated, -10.0);
    let saturated = rustaops::saturate(&contrasted, -20.0);
    let brightened = rustaops::brighten_by_percent(&saturated, 20.0);

    rustaops::restore_transparency(&brightened)
}

pub fn apply_brannan(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let with_sepia = rustaops::sepia(img, 20.0);
    let contrasted = imageops::contrast(&with_sepia, 20.0);
    let foreground = rustaops::fill_with_channels(width, height, &[161, 44, 199, 59]);

    rustaops::blend_lighten(&foreground, &contrasted)
}

pub fn apply_brooklyn(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, -10.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, 10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[168, 223, 193, 150]);
    let background = rustaops::restore_transparency(&brightened);

    rustaops::blend_overlay(&foreground, &background)
}

pub fn apply_clarendon(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, 20.0);
    let saturated = rustaops::saturate(&contrasted, 35.0);
    let foreground = rustaops::fill_with_channels(width, height, &[127, 187, 227, 101]);

    rustaops::blend_overlay(&foreground, &saturated)
}

pub fn apply_earlybird(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, -10.0);
    let with_sepia = rustaops::sepia(&contrasted, 5.0);
    let foreground = rustaops::fill_with_channels(width, height, &[208, 186, 142, 150]);
    let out = rustaops::blend_overlay(&with_sepia, &foreground);

    rustaops::restore_transparency(&out)
}

pub fn apply_gingham(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let brightened = rustaops::brighten_by_percent(img, 5.0);
    let background = imageops::huerotate(&brightened, -10);
    let foreground = rustaops::fill_with_channels(width, height, &[230, 230, 230, 255]);

    rustaops::blend_soft_light(&foreground, &background)
}

pub fn apply_hudson(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let brightened = rustaops::brighten_by_percent(img, 50.0);
    let constrasted = imageops::contrast(&brightened, -10.0);
    let saturated = rustaops::saturate(&constrasted, 10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[166, 177, 255, 208]);
    let blended = rustaops::blend_multiply(&foreground, &saturated);

    rustaops::restore_transparency(&blended)
}

pub fn apply_inkwell(img: &RgbaImage) -> RgbaImage {
    let with_sepia = rustaops::sepia(img, 30.0);
    let contrasted = imageops::contrast(&with_sepia, 10.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, 10.0);
    let out = imageops::grayscale(&brightened);
    ConvertBuffer::convert(&out)
}

pub fn apply_kelvin(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let foreground = rustaops::fill_with_channels(width, height, &[56, 44, 52, 255]);
    let color_dodged = rustaops::blend_color_dodge(img, &foreground);
    let foreground = rustaops::fill_with_channels(width, height, &[183, 125, 33, 255]);

    rustaops::blend_overlay(&foreground, &color_dodged)
}

pub fn apply_lark(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, -10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[34, 37, 63, 255]);
    let color_dodged = rustaops::blend_color_dodge(&contrasted, &foreground);
    let foreground = rustaops::fill_with_channels(width, height, &[242, 242, 242, 204]);

    rustaops::blend_darken(&foreground, &color_dodged)
}

pub fn apply_lofi(img: &RgbaImage) -> RgbaImage {
    let saturated = rustaops::saturate(img, 10.0);

    imageops::contrast(&saturated, 50.0)
}

pub fn apply_maven(img: &RgbaImage) -> RgbaImage {
    let with_sepia = rustaops::sepia(img, 25.0);
    let brightened = rustaops::brighten_by_percent(&with_sepia, -0.05);
    let contrasted = imageops::contrast(&brightened, -0.05);

    rustaops::saturate(&contrasted, 50.0)
}

pub fn apply_mayfair(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, 10.0);
    let saturated = rustaops::saturate(&contrasted, 10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[255, 200, 200, 153]);

    rustaops::blend_overlay(&foreground, &saturated)
}

pub fn apply_moon(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, 10.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, 10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[160, 160, 160, 255]);
    let soft_light = rustaops::blend_soft_light(&foreground, &brightened);
    let foreground = rustaops::fill_with_channels(width, height, &[56, 56, 56, 255]);
    let lighten = rustaops::blend_lighten(&foreground, &soft_light);
    let out = imageops::grayscale(&lighten);
    ConvertBuffer::convert(&out)
}

pub fn apply_nashville(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let with_sepia = rustaops::sepia(img, 2.0);
    let contrasted = imageops::contrast(&with_sepia, 20.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, 5.0);
    let saturated = rustaops::saturate(&brightened, 20.0);
    let foreground = rustaops::fill_with_channels(width, height, &[247, 176, 153, 243]);
    let darkened = rustaops::blend_darken(&foreground, &saturated);
    let foreground = rustaops::fill_with_channels(width, height, &[0, 70, 150, 230]);

    rustaops::blend_lighten(&foreground, &darkened)
}

pub fn apply_reyes(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let with_sepia = rustaops::sepia(img, 22.0);
    let brightened = rustaops::brighten_by_percent(&with_sepia, 10.0);
    let contrast = imageops::contrast(&brightened, -15.0);
    let saturated = rustaops::saturate(&contrast, -25.0);
    let foreground = rustaops::fill_with_channels(width, height, &[239, 205, 173, 10]);

    rustaops::over(&foreground, &saturated)
}

pub fn apply_rise(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let brightened = rustaops::brighten_by_percent(img, 5.0);
    let with_sepia = rustaops::sepia(&brightened, 5.0);
    let contrast = imageops::contrast(&with_sepia, -10.0);
    let saturated = rustaops::saturate(&contrast, -10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[236, 205, 169, 240]);
    let multiply = rustaops::blend_multiply(&foreground, &saturated);
    let foreground = rustaops::fill_with_channels(width, height, &[232, 197, 152, 10]);
    let overlaid = rustaops::blend_overlay(&foreground, &multiply);

    rustaops::over(&overlaid, img)
}

pub fn apply_slumber(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let saturated = rustaops::saturate(img, -34.0);
    let brightened = rustaops::brighten_by_percent(&saturated, 5.0);
    let foreground = rustaops::fill_with_channels(width, height, &[69, 41, 12, 102]);
    let lightened = rustaops::blend_lighten(&foreground, &brightened);
    let foreground = rustaops::fill_with_channels(width, height, &[125, 105, 24, 128]);

    rustaops::blend_soft_light(&foreground, &lightened)
}

pub fn apply_stinson(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, -25.0);
    let saturated = rustaops::saturate(&contrasted, -15.0);
    let brightened = rustaops::brighten_by_percent(&saturated, 15.0);
    let foreground = rustaops::fill_with_channels(width, height, &[240, 149, 128, 51]);

    rustaops::blend_soft_light(&foreground, &brightened)
}

pub fn apply_toaster(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, 20.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, -10.0);
    let foreground = rustaops::fill_with_channels(width, height, &[128, 78, 15, 140]);

    rustaops::blend_screen(&foreground, &brightened)
}

pub fn apply_valencia(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let contrasted = imageops::contrast(img, 8.0);
    let brightened = rustaops::brighten_by_percent(&contrasted, 8.0);
    let sepia = rustaops::sepia(&brightened, 8.0);
    let foreground = rustaops::fill_with_channels(width, height, &[58, 3, 57, 128]);

    rustaops::blend_exclusion(&foreground, &sepia)
}

pub fn apply_walden(img: &RgbaImage) -> RgbaImage {
    let (width, height) = img.dimensions();
    let brightened = rustaops::brighten_by_percent(img, 10.0);
    let huerotated = imageops::huerotate(&brightened, -10);
    let saturated = rustaops::saturate(&huerotated, 60.0);
    let sepia = rustaops::sepia(&saturated, 5.0);
    let foreground = rustaops::fill_with_channels(width, height, &[0, 88, 244, 77]);

    rustaops::blend_screen(&foreground, &sepia)
}
