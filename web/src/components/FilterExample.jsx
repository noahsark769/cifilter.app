import React from 'react';
import styled from 'styled-components';
import FilterExampleImage from './FilterExampleImage';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';
import { IoIosArrowRoundDown } from 'react-icons/io';

const Container = styled.div`

`;

const ImageList = styled.div`
    display: flex;
    flex-direction: row;
`;

const Wrapper = styled.div`
    flex: 1;
    &:first-child {
        margin-right: 20px;
    }
`;

const OutputImageWrapper = styled.div`
    flex: 2;
    &:first-child {
        margin-right: 20px;
    }
`;

const OutputImageSpacer = styled.div`
    flex: 1;
`;

const ArrowContainer = styled.div`
    display: flex;
    justify-content: center;
    margin: 20px 0;
`;

const FilterExample = (props) => {
    console.log(props);
    const outputImageFilename = props.example.data.outputImage.image;
    return (
        <Container>
            <FilterDetailSectionHeading>Example</FilterDetailSectionHeading>
            <ImageList>
                {Object.entries(props.example.data).map((entry) => {
                    const [name, data] = entry;
                    if (name === "_metadata") { return null; }
                    if (data.type !== "image") { return null; }
                    if (name === "outputImage") { return null; }
                    return (
                        <Wrapper>
                            <FilterExampleImage
                                key={name}
                                name={name}
                                filename={`${props.example.basepath}/${data.image}`}
                            />
                        </Wrapper>);
                })}
            </ImageList>
            <ArrowContainer>
                <IoIosArrowRoundDown size={50} color="#999" />
            </ArrowContainer>
            <ImageList>
                <OutputImageSpacer />
                <OutputImageWrapper>
                    <FilterExampleImage
                        name="outputImage"
                        filename={`${props.example.basepath}/${outputImageFilename}`}
                    />
                </OutputImageWrapper>
                <OutputImageSpacer />
            </ImageList>
        </Container>
    )
};
export default FilterExample;